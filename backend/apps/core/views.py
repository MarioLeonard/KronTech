from django.http import JsonResponse

from common.authentication import firebase_required


def health_check(request):
    """Health check endpoint - no authentication required."""
    return JsonResponse({"status": "ok"})


@firebase_required
def profile(request):
    """
    Protected endpoint that returns authenticated user profile.

    Requires Firebase ID token in Authorization header.

    Header format:
        Authorization: Bearer <firebase-id-token>

    Returns:
        JSON with user profile information from Firebase token
    """
    user = request.auth_user

    return JsonResponse(
        {
            "message": "Successfully authenticated!",
            "user": {
                "uid": user.get("uid"),
                "email": user.get("email"),
                "email_verified": user.get("email_verified"),
                "display_name": user.get("display_name"),
                "photo_url": user.get("photo_url"),
            },
        }
    )
