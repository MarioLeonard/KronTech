"""Gemini-backed service for generated trip itineraries."""

import json
import logging
import urllib.error
import urllib.parse
import urllib.request
from typing import Optional

from decouple import config

logger = logging.getLogger(__name__)


class GeminiTripGenerationError(Exception):
    """Raised when Gemini trip generation fails in a controlled way."""


class GeminiTripGenerationService:
    """Generate travel itineraries through Gemini using a backend-held API key."""

    DEFAULT_MODEL = "gemini-2.5-flash"
    ENDPOINT_HOST = "generativelanguage.googleapis.com"

    @classmethod
    def generate_trip(cls, request_data: dict) -> dict:
        cls._validate_request(request_data)

        api_key = config("GEMINI_API_KEY", default="").strip()
        if not api_key:
            raise GeminiTripGenerationError(
                "Gemini configuration is missing on the backend. Check GEMINI_API_KEY."
            )

        model = config("GEMINI_MODEL", default=cls.DEFAULT_MODEL).strip()
        endpoint = cls._build_endpoint(model=model, api_key=api_key)
        payload = cls._build_payload(request_data)

        logger.info(
            "Starting Gemini trip request. model=%s cities=%s start=%s end=%s",
            model,
            ", ".join(request_data.get("cities", [])),
            request_data.get("startDate"),
            request_data.get("endDate"),
        )

        response_body = cls._post_json(endpoint, payload)
        generated_text = cls._extract_generated_text(response_body)
        trip = cls._parse_generated_trip(generated_text)

        if not cls._has_useful_content(trip):
            raise GeminiTripGenerationError(
                "The response did not contain a useful itinerary. Please try again."
            )

        return trip

    @classmethod
    def _validate_request(cls, request_data: dict) -> None:
        if not isinstance(request_data, dict):
            raise ValueError("Request body must be a JSON object.")

        cities = request_data.get("cities")
        start_date = request_data.get("startDate")
        end_date = request_data.get("endDate")
        interests = request_data.get("interests")

        if not isinstance(cities, list) or not any(
            isinstance(city, str) and city.strip() for city in cities
        ):
            raise ValueError("cities must contain at least one city.")
        if not isinstance(start_date, str) or not start_date.strip():
            raise ValueError("startDate is required.")
        if not isinstance(end_date, str) or not end_date.strip():
            raise ValueError("endDate is required.")
        if not isinstance(interests, list) or not interests:
            raise ValueError("interests must contain at least one interest.")

    @classmethod
    def _build_endpoint(cls, model: str, api_key: str) -> str:
        query = urllib.parse.urlencode({"key": api_key})
        return (
            f"https://{cls.ENDPOINT_HOST}/v1beta/models/"
            f"{urllib.parse.quote(model)}:generateContent?{query}"
        )

    @classmethod
    def _build_payload(cls, request_data: dict) -> dict:
        return {
            "contents": [
                {
                    "role": "user",
                    "parts": [{"text": cls._build_prompt(request_data)}],
                }
            ],
            "generationConfig": {
                "temperature": 0.7,
                "responseMimeType": "application/json",
            },
        }

    @classmethod
    def _post_json(cls, endpoint: str, payload: dict) -> dict:
        encoded_payload = json.dumps(payload).encode("utf-8")
        request = urllib.request.Request(
            endpoint,
            data=encoded_payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )

        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                body = response.read().decode("utf-8")
                logger.debug("Gemini response body: %s", cls._truncate(body))
                return json.loads(body)
        except urllib.error.HTTPError as error:
            body = error.read().decode("utf-8")
            logger.warning(
                "Gemini HTTP error. status=%s body=%s",
                error.code,
                cls._truncate(body),
            )
            message = cls._read_friendly_error_message(error.code, body)
            raise GeminiTripGenerationError(
                f"Gemini a returnat o eroare ({error.code})"
                f"{': ' + message if message else ''}"
            ) from error
        except urllib.error.URLError as error:
            logger.warning("Gemini network error: %s", error)
            raise GeminiTripGenerationError(
                "Could not contact Gemini. Check the backend connection."
            ) from error
        except TimeoutError as error:
            raise GeminiTripGenerationError(
                "Generation took too long. Please try again."
            ) from error
        except json.JSONDecodeError as error:
            raise GeminiTripGenerationError(
                "Gemini did not return a valid JSON response."
            ) from error

    @classmethod
    def _extract_generated_text(cls, response_body: dict) -> str:
        candidates = response_body.get("candidates")
        if not isinstance(candidates, list) or not candidates:
            raise GeminiTripGenerationError("Gemini did not return content.")

        content = candidates[0].get("content") if isinstance(candidates[0], dict) else None
        parts = content.get("parts") if isinstance(content, dict) else None
        if not isinstance(parts, list):
            raise GeminiTripGenerationError("Gemini did not return text.")

        text = "".join(
            part.get("text", "") for part in parts if isinstance(part, dict)
        ).strip()
        if not text:
            raise GeminiTripGenerationError("Gemini did not return text.")

        logger.debug("Gemini generated text: %s", cls._truncate(text))
        return text

    @classmethod
    def _parse_generated_trip(cls, generated_text: str) -> dict:
        text = generated_text.strip()
        if text.startswith("```"):
            text = text.removeprefix("```json").removeprefix("```").strip()
            text = text.removesuffix("```").strip()

        try:
            trip = json.loads(text)
        except json.JSONDecodeError as error:
            raise GeminiTripGenerationError(
                "The response did not have the expected JSON format."
            ) from error

        if not isinstance(trip, dict):
            raise GeminiTripGenerationError(
                "The response did not have the expected format."
            )

        return trip

    @staticmethod
    def _has_useful_content(trip: dict) -> bool:
        days = trip.get("days")
        if not isinstance(days, list) or not days:
            return False

        return any(
            isinstance(day, dict)
            and isinstance(day.get("activities"), list)
            and len(day["activities"]) > 0
            for day in days
        )

    @classmethod
    def _read_friendly_error_message(
        cls,
        status_code: int,
        body: str,
    ) -> Optional[str]:
        try:
            decoded = json.loads(body)
        except json.JSONDecodeError:
            return None

        error = decoded.get("error") if isinstance(decoded, dict) else None
        if not isinstance(error, dict):
            return None

        if status_code == 429 or error.get("status") == "RESOURCE_EXHAUSTED":
            retry_delay = cls._read_retry_delay(error.get("details"))
            return (
                "the Gemini quota is exceeded or unavailable for the "
                "configured model. Check the plan, billing, and project limits."
                f"{' Retry after ' + retry_delay + '.' if retry_delay else ''}"
            )

        message = error.get("message")
        return message.strip() if isinstance(message, str) and message.strip() else None

    @staticmethod
    def _read_retry_delay(details: object) -> Optional[str]:
        if not isinstance(details, list):
            return None

        for item in details:
            if isinstance(item, dict) and isinstance(item.get("retryDelay"), str):
                return item["retryDelay"]

        return None

    @staticmethod
    def _truncate(value: str, max_length: int = 4000) -> str:
        if len(value) <= max_length:
            return value
        return f"{value[:max_length]}... [truncated {len(value) - max_length} chars]"

    @staticmethod
    def _build_prompt(request_data: dict) -> str:
        request_json = json.dumps(request_data, ensure_ascii=False, indent=2)
        return f"""
You are a senior travel planning assistant. Generate a complete, polished trip
itinerary that can be saved directly in a travel app.

Return ONLY valid JSON. Do not include markdown, comments, explanations, or text outside the JSON object.

User request JSON:
{request_json}

Important requirements:
- Use English for every human-readable string, regardless of the request locale.
- Match the requested cities, dates, interests, currency, and distance unit.
- Organize the itinerary by day, with one object for every calendar day from startDate through endDate.
- Include recommended activities with approximate time ranges.
- The day activities are also used as the app's "Places to visit" list. Include only tourist attractions, landmarks, museums, viewpoints, parks, cultural sites, beaches, neighborhoods worth visiting, or similar visit-worthy places. Do not include accommodation, hotel check-in/check-out, airport/train transfers, transit steps, meals, restaurants, shopping errands, rest periods, or administrative tasks as activities.
- Each activity title must be a clean tourist objective name, not a sentence.
- Activity descriptions should explain why the place is worth visiting and what to expect there.
- Include approximate cost for each activity and each day.
- Include approximate distances in kilometers between objectives.
- Include approximate travel duration between locations.
- Include 3 to 6 recommended accommodation options that fit the trip style and budget implied by the interests.
- For accommodation names, return only the property or accommodation name. Do not append platform labels such as "(Airbnb)", "(Booking)", "(Booking.com)", or similar text in parentheses.
- Accommodation type must be concise, such as hotel, apartment, hostel, guesthouse, villa, or boutique hotel.
- Include destinationImageUrl with a direct HTTPS URL to an actual image file for the main destination/city. The URL must be public, accessible in a normal browser without authentication, API keys, cookies, referrer requirements, expiring signatures, or login walls.
- destinationImageUrl must point directly to image bytes, not to an HTML page, search result, gallery page, or API endpoint. Prefer stable Wikimedia Commons upload URLs, images from official tourism/open public sites, or Unsplash images only when the URL is a direct publicly accessible image URL. Avoid Google Images, Pinterest, Instagram, Facebook, blob URLs, data URLs, and protected CDN links.
- If you are not confident the destinationImageUrl is a real public image URL that can load directly in a browser, return an empty string instead of guessing.
- For Booking or Airbnb, do not claim live availability. Mark every option as a search suggestion and provide search URLs for the city/property search.
- Include 3 to 6 restaurants or places to eat with realistic cuisine, area, estimated meal cost, and a short practical note.
- Costs, distances, and durations are estimates and must be marked as approximate.
- Prefer realistic pacing. Do not overload days.
- Avoid inventing exact live prices or availability.
- If information is uncertain, include it in assumptions or warnings.
- Keep titles, summaries, notes, assumptions, and warnings concise but useful.
- The final JSON should feel like a ready-to-use saved trip, not a draft or generic template.

JSON schema:
{{
  "title": "string",
  "summary": "string",
  "cities": ["string"],
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "currency": "string",
  "destinationImageUrl": "direct public HTTPS image URL, or empty string if uncertain",
  "costSummary": {{
    "estimatedTotal": 0,
    "estimatedActivitiesTotal": 0,
    "estimatedFoodTotal": 0,
    "estimatedAccommodationTotal": 0,
    "note": "string"
  }},
  "distanceSummary": {{
    "estimatedTotalKm": 0,
    "estimatedTotalTransitDuration": "string",
    "note": "string"
  }},
  "days": [
    {{
      "dayNumber": 1,
      "date": "YYYY-MM-DD",
      "title": "string",
      "city": "string",
      "summary": "string",
      "estimatedCost": 0,
      "estimatedDistanceKm": 0,
      "estimatedTransitDuration": "string",
      "activities": [
        {{
          "timeRange": "string",
          "title": "tourist objective or place to visit only",
          "location": "specific attraction/place name or address area",
          "description": "why this tourist objective is worth visiting, without check-in, accommodation, meal, or transit instructions",
          "estimatedCost": 0,
          "costNote": "string",
          "distanceFromPreviousKm": 0,
          "travelTimeFromPrevious": "string",
          "transportMode": "walking/public_transport/taxi/car/train/other",
          "tags": ["string"],
          "isVisited": false
        }}
      ],
      "mealSuggestions": ["string"]
    }}
  ],
  "accommodations": [
    {{
      "name": "property or accommodation name only, without platform labels in parentheses",
      "city": "string",
      "area": "string",
      "type": "hotel/apartment/hostel/guesthouse/other",
      "estimatedNightlyCost": 0,
      "source": "Booking/Airbnb/Search suggestion/Other",
      "bookingSearchUrl": "string",
      "airbnbSearchUrl": "string",
      "isSearchSuggestion": true,
      "note": "string"
    }}
  ],
  "restaurants": [
    {{
      "name": "string",
      "city": "string",
      "area": "string",
      "cuisine": "string",
      "recommendedFor": "breakfast/lunch/dinner/snack",
      "estimatedMealCost": 0,
      "note": "string"
    }}
  ],
  "assumptions": ["string"],
  "warnings": ["string"]
}}

Validation rules:
- Return at least one day.
- Return 2 to 4 tourist activities per day unless the trip duration makes that impossible.
- Return at least 3 accommodation options and at least 3 restaurant options when possible.
- Use numeric values for costs and distances.
- Keep URLs as search URLs when live availability cannot be verified.
- destinationImageUrl must be a real browser-accessible image URL with no authentication.
- Do not include Romanian text anywhere in the JSON.
""".strip()
