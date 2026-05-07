from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

from common.authentication import firebase_required
from common.services.onboarding_service import (
    OnboardingService,
    OnboardingValidationError,
)
from common.services.profile_service import ProfileService


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
def profile(request):
    """
    Protected endpoint that returns authenticated user profile from Firestore.

    Requires Firebase ID token in Authorization header.

    Header format:
        Authorization: Bearer <firebase-id-token>

    Methods:
        GET: Retrieve user profile

    Returns:
        JSON with user profile information from Firestore
    """
    auth_user = request.auth_user

    if request.method == "GET":
        try:
            # Get or create profile from Firestore
            user_profile = ProfileService.get_or_create_profile(auth_user)

            return JsonResponse(
                {
                    "message": "Successfully retrieved profile!",
                    "profile": user_profile.to_dict(),
                }
            )
        except Exception as e:
            return JsonResponse(
                {"error": f"Failed to retrieve profile: {str(e)}"},
                status=500,
            )

    return JsonResponse(
        {"error": "Method not allowed. Use GET."},
        status=405,
    )


@csrf_exempt
@firebase_required
def complete_onboarding(request):
    """
    Complete onboarding for the authenticated Firebase user.

    Only the backend writes onboarding profile fields to Firestore. The client
    must provide a valid Firebase ID token in the Authorization header.
    """
    if request.method != "POST":
        return JsonResponse(
            {"error": "Method not allowed. Use POST."},
            status=405,
        )

    try:
        body = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse(
            {"error": "Invalid JSON in request body"},
            status=400,
        )

    try:
        user_profile = OnboardingService.complete_onboarding(
            request.auth_user,
            body,
        )
        return JsonResponse(
            {
                "message": "Onboarding completed successfully!",
                "profile": user_profile.to_dict(),
            },
            status=200,
        )
    except OnboardingValidationError as error:
        return JsonResponse(
            {"error": "Validation failed", "message": str(error)},
            status=400,
        )
    except Exception as error:
        return JsonResponse(
            {"error": f"Failed to complete onboarding: {str(error)}"},
            status=500,
        )
