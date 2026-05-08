from django.http import JsonResponse
import json

from common.authentication import firebase_required
from common.services.profile_service import ProfileService


def health_check(request):
    """Health check endpoint - no authentication required."""
    return JsonResponse({"status": "ok"})


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
