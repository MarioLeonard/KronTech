from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

from common.authentication import firebase_required
from common.services.onboarding_service import (
    OnboardingService,
    OnboardingValidationError,
)
from common.services.profile_service import ProfileService
from common.services.trip_service import TripService


def health_check(request):
    """Health check endpoint - no authentication required."""
    return JsonResponse({"status": "ok"})


@csrf_exempt
@firebase_required
def signup(request):
    """
    Signup endpoint that creates a user profile in Firestore.

    Requires Firebase ID token in Authorization header after Firebase Auth signup.

    Header format:
        Authorization: Bearer <firebase-id-token>

    Request body (optional):
        {
            "display_name": "John Doe",
            "photo_url": "https://...",
            "bio": "User bio",
            "location": "City, Country"
        }

    Returns:
        JSON with newly created user profile

    Raises:
        400: If token validation fails
        500: If profile creation fails
    """
    if request.method != "POST":
        return JsonResponse(
            {"error": "Method not allowed. Use POST."},
            status=405,
        )

    try:
        auth_user = request.auth_user
        user_profile = ProfileService.get_or_create_profile(auth_user)

        return JsonResponse(
            {
                "message": "User registered successfully!",
                "profile": user_profile.to_dict(),
            },
            status=201,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Registration failed: {str(e)}"},
            status=500,
        )


@csrf_exempt
@firebase_required
def get_profile(request):
    """
    GET /api/profile/ - Retrieve authenticated user profile from Firestore.

    Requires Firebase ID token in Authorization header.

    Header format:
        Authorization: Bearer <firebase-id-token>

    Returns:
        JSON with user profile information from Firestore
        Status: 200 on success, 500 on error
    """
    if request.method != "GET":
        return JsonResponse(
            {"error": "Method not allowed. Use GET."},
            status=405,
        )

    try:
        auth_user = request.auth_user
        uid = auth_user.get("uid")

        # Get or create profile from Firestore
        user_profile = ProfileService.get_or_create_profile(auth_user)

        return JsonResponse(
            {
                "message": "Successfully retrieved profile!",
                "profile": user_profile.to_dict(),
            },
            status=200,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to retrieve profile: {str(e)}"},
            status=500,
        )


@csrf_exempt
def profile(request):
    """Dispatch profile requests by HTTP method."""
    if request.method == "GET":
        return get_profile(request)
    if request.method == "PATCH":
        return update_profile(request)
    return JsonResponse(
        {"error": "Method not allowed. Use GET or PATCH."},
        status=405,
    )


@firebase_required
def update_profile(request):
    """
    PATCH /api/profile/ - Update authenticated user profile fields.

    Requires Firebase ID token in Authorization header.
    UID validation: UID is always extracted from the token, NOT from request body.

    Allowed fields to update:
    - firstName
    - lastName
    - dateOfBirth
    - gender
    - country
    - city
    - street

    Non-whitelisted fields are silently ignored.

    Header format:
        Authorization: Bearer <firebase-id-token>

    Request body:
        {
            "firstName": "John",
            "lastName": "Doe",
            "dateOfBirth": "1990-01-01",
            "gender": "M",
            "country": "Romania",
            "city": "Bucharest",
            "street": "Main St 123"
        }

    Returns:
        JSON with updated user profile
        Status: 200 on success, 400 on invalid JSON, 500 on error
    """
    if request.method != "PATCH":
        return JsonResponse(
            {"error": "Method not allowed. Use PATCH."},
            status=405,
        )

    try:
        # Extract UID from token (not from body) 
        auth_user = request.auth_user
        uid = auth_user.get("uid")

        # Parse request body
        try:
            body = json.loads(request.body)
        except json.JSONDecodeError:
            return JsonResponse(
                {"error": "Invalid JSON in request body"},
                status=400,
            )

        # Update profile with field validation (only whitelisted fields)
        user_profile = ProfileService.update_profile(uid, body)

        return JsonResponse(
            {
                "message": "Profile updated successfully!",
                "profile": user_profile.to_dict(),
            },
            status=200,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to update profile: {str(e)}"},
            status=500,
        )


@firebase_required
def upload_profile_photo(request):
    """
    POST /api/profile/photo/ - Upload profile photo to Firebase Storage.

    Requires Firebase ID token in Authorization header.
    UID validation: UID is always extracted from the token, NOT from request body.

    Allowed file types: JPEG, PNG, WebP, GIF
    Max file size: 5MB

    Photo is stored at: gs://krontech-7fbdb.appspot.com/users/{uid}/profile/...
    Only the URL is saved in Firestore.

    Header format:
        Authorization: Bearer <firebase-id-token>

    Request:
        Multipart form data with file in 'photo' field

    Returns:
        JSON with updated user profile including new photo URL
        Status: 201 on success, 400 on validation error, 500 on error
    """
    if request.method != "POST":
        return JsonResponse(
            {"error": "Method not allowed. Use POST."},
            status=405,
        )

    try:
        # Extract UID from token (not from body)
        auth_user = request.auth_user
        uid = auth_user.get("uid")

        # Get uploaded file
        if "photo" not in request.FILES:
            return JsonResponse(
                {"error": "No file provided. Use 'photo' field in multipart form data."},
                status=400,
            )

        uploaded_file = request.FILES["photo"]

        # Validate file
        if uploaded_file.size == 0:
            return JsonResponse(
                {"error": "File is empty"},
                status=400,
            )

        # Read file content
        file_content = uploaded_file.read()
        content_type = uploaded_file.content_type or "application/octet-stream"

        # Upload photo and update profile
        user_profile = ProfileService.upload_profile_photo(
            uid=uid,
            file_content=file_content,
            filename=uploaded_file.name,
            content_type=content_type,
        )

        return JsonResponse(
            {
                "message": "Profile photo uploaded successfully!",
                "profile": user_profile.to_dict(),
            },
            status=201,
        )

    except ValueError as e:
        # Validation errors from ProfileService
        return JsonResponse(
            {"error": str(e)},
            status=400,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to upload profile photo: {str(e)}"},
            status=500,
        )


# ============================================================================
# TRIP ENDPOINTS
# ============================================================================


@firebase_required
def create_trip(request):
    """
    POST /api/trips/ - Create a new trip.

    Requires Firebase ID token in Authorization header.

    Request body:
        {
            "startLocation": {
                "latitude": 44.4268,
                "longitude": 26.1025,
                "address": "Bucharest, Romania"
            },
            "destination": {
                "latitude": 45.9432,
                "longitude": 24.9668,
                "address": "Brașov, Romania"
            },
            "dateTime": "2026-05-15T10:30:00Z",
            "waypoints": [
                {
                    "latitude": 45.0,
                    "longitude": 25.5,
                    "address": "Some waypoint"
                }
            ],
            "distance": 166.5,
            "duration": "2h 30m",
            "status": "planned"
        }

    Returns:
        JSON with created trip
        Status: 201 on success, 400 on validation error, 500 on error
    """
    if request.method != "POST":
        return JsonResponse(
            {"error": "Method not allowed. Use POST."},
            status=405,
        )

    try:
        auth_user = request.auth_user
        owner_uid = auth_user.get("uid")

        # Parse request body
        try:
            body = json.loads(request.body)
        except json.JSONDecodeError:
            return JsonResponse(
                {"error": "Invalid JSON in request body"},
                status=400,
            )

        # Extract and validate required fields
        start_location = body.get("startLocation")
        destination = body.get("destination")
        date_time = body.get("dateTime")

        if not all([start_location, destination, date_time]):
            return JsonResponse(
                {
                    "error": "Missing required fields: startLocation, destination, dateTime"
                },
                status=400,
            )

        # Create trip
        trip = TripService.create_trip(
            owner_uid=owner_uid,
            start_location=start_location,
            destination=destination,
            date_time=date_time,
            waypoints=body.get("waypoints"),
            distance=body.get("distance"),
            duration=body.get("duration"),
            status=body.get("status", "planned"),
        )

        return JsonResponse(
            {
                "message": "Trip created successfully!",
                "trip": trip.to_dict(),
            },
            status=201,
        )

    except ValueError as e:
        return JsonResponse(
            {"error": str(e)},
            status=400,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to create trip: {str(e)}"},
            status=500,
        )


@firebase_required
def list_trips(request):
    """
    GET /api/trips/ - List all trips for authenticated user.

    Requires Firebase ID token in Authorization header.

    Returns:
        JSON with list of user's trips
        Status: 200 on success, 500 on error
    """
    if request.method != "GET":
        return JsonResponse(
            {"error": "Method not allowed. Use GET."},
            status=405,
        )

    try:
        auth_user = request.auth_user
        owner_uid = auth_user.get("uid")

        # Get all trips for user
        trips = TripService.get_user_trips(owner_uid)

        return JsonResponse(
            {
                "message": "Trips retrieved successfully!",
                "trips": [trip.to_dict() for trip in trips],
            },
            status=200,
        )

    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to retrieve trips: {str(e)}"},
            status=500,
        )


@firebase_required
def get_trip(request, trip_id):
    """
    GET /api/trips/{id}/ - Get details of a specific trip.

    Requires Firebase ID token in Authorization header.
    User must own the trip.

    Returns:
        JSON with trip details
        Status: 200 on success, 403 on permission denied, 404 on not found, 500 on error
    """
    if request.method != "GET":
        return JsonResponse(
            {"error": "Method not allowed. Use GET."},
            status=405,
        )

    try:
        auth_user = request.auth_user
        owner_uid = auth_user.get("uid")

        # Get trip with permission check
        trip = TripService.get_trip(trip_id, owner_uid)

        if not trip:
            return JsonResponse(
                {"error": "Trip not found"},
                status=404,
            )

        return JsonResponse(
            {
                "message": "Trip retrieved successfully!",
                "trip": trip.to_dict(),
            },
            status=200,
        )

    except PermissionError as e:
        return JsonResponse(
            {"error": str(e)},
            status=403,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to retrieve trip: {str(e)}"},
            status=500,
        )


@firebase_required
def update_trip(request, trip_id):
    """
    PATCH /api/trips/{id}/ - Update a trip.

    Requires Firebase ID token in Authorization header.
    User must own the trip.

    Allowed fields:
    - startLocation
    - destination
    - waypoints
    - dateTime
    - distance
    - duration
    - status

    Returns:
        JSON with updated trip
        Status: 200 on success, 400 on validation error, 403 on permission denied, 404 on not found, 500 on error
    """
    if request.method != "PATCH":
        return JsonResponse(
            {"error": "Method not allowed. Use PATCH."},
            status=405,
        )

    try:
        auth_user = request.auth_user
        owner_uid = auth_user.get("uid")

        # Parse request body
        try:
            body = json.loads(request.body)
        except json.JSONDecodeError:
            return JsonResponse(
                {"error": "Invalid JSON in request body"},
                status=400,
            )

        # Update trip with permission check
        trip = TripService.update_trip(trip_id, owner_uid, body)

        return JsonResponse(
            {
                "message": "Trip updated successfully!",
                "trip": trip.to_dict(),
            },
            status=200,
        )

    except PermissionError as e:
        return JsonResponse(
            {"error": str(e)},
            status=403,
        )
    except ValueError as e:
        return JsonResponse(
            {"error": str(e)},
            status=400,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to update trip: {str(e)}"},
            status=500,
        )


@firebase_required
def delete_trip(request, trip_id):
    """
    DELETE /api/trips/{id}/ - Delete a trip.

    Requires Firebase ID token in Authorization header.
    User must own the trip.

    Returns:
        JSON confirmation
        Status: 200 on success, 403 on permission denied, 404 on not found, 500 on error
    """
    if request.method != "DELETE":
        return JsonResponse(
            {"error": "Method not allowed. Use DELETE."},
            status=405,
        )

    try:
        auth_user = request.auth_user
        owner_uid = auth_user.get("uid")

        # Delete trip with permission check
        TripService.delete_trip(trip_id, owner_uid)

        return JsonResponse(
            {
                "message": "Trip deleted successfully!",
            },
            status=200,
        )

    except PermissionError as e:
        return JsonResponse(
            {"error": str(e)},
            status=403,
        )
    except ValueError as e:
        return JsonResponse(
            {"error": str(e)},
            status=404,
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Failed to delete trip: {str(e)}"},
            status=500,
        )
