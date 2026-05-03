from django.http import JsonResponse

from common.authentication import firebase_required
from common.services.profile_service import ProfileService


def health_check(request):
    """Health check endpoint - no authentication required."""
    return JsonResponse({"status": "ok"})


@firebase_required
def profile(request):
    """
    Protected endpoint that returns authenticated user profile from Firestore.

    Requires Firebase ID token in Authorization header.

    Header format:
        Authorization: Bearer <firebase-id-token>

    Methods:
        GET: Retrieve user profile
        POST: Create or update user profile

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

    elif request.method == "POST":
        import json

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
