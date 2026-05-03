from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

from common.authentication import firebase_required
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
        
        # Get or create profile from Firebase auth data
        user_profile = ProfileService.get_or_create_profile(auth_user)

        # Update with additional data if provided
        try:
            body = json.loads(request.body)
            if body:
                user_profile.update(body)
        except json.JSONDecodeError:
            pass  # No additional data provided

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
        PUT/PATCH: Update user profile

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

    elif request.method in ["POST", "PUT", "PATCH"]:
        try:
            body = json.loads(request.body)
            uid = auth_user.get("uid")

            # Update profile in Firestore
            user_profile = ProfileService.update_profile(uid, body)

            return JsonResponse(
                {
                    "message": "Profile updated successfully!",
                    "profile": user_profile.to_dict(),
                }
            )
        except json.JSONDecodeError:
            return JsonResponse(
                {"error": "Invalid JSON in request body"},
                status=400,
            )
        except Exception as e:
            return JsonResponse(
                {"error": f"Failed to update profile: {str(e)}"},
                status=500,
            )

    else:
        return JsonResponse(
            {"error": "Method not allowed"},
            status=405,
        )
