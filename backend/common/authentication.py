"""Authentication utilities for Firebase token validation."""

import logging
from functools import wraps
from typing import Callable, Optional

from django.http import JsonResponse

from .firebase.auth import firebase_auth
from .firebase.exceptions import (
    FirebaseAuthenticationError,
    InvalidTokenError,
    TokenExpiredError,
)
from .firebase.types import AuthenticatedUser

logger = logging.getLogger(__name__)


def firebase_required(view_func: Callable) -> Callable:
    """
    Decorator to require Firebase authentication for a view.

    This decorator:
    1. Extracts the Firebase ID token from the Authorization header
    2. Validates the token with Firebase
    3. Attaches the authenticated user to the request
    4. Returns 401 Unauthorized if token is missing or invalid

    Usage:
        @firebase_required
        def my_protected_view(request):
            user: AuthenticatedUser = request.auth_user
            return JsonResponse({"message": f"Hello {user['uid']}"})

    Args:
        view_func: The view function to protect

    Returns:
        Wrapped view function that checks authentication
    """

    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        try:
            # Extract token from Authorization header
            auth_header = request.META.get("HTTP_AUTHORIZATION", "")

            if not auth_header:
                logger.debug("No Authorization header provided")
                return JsonResponse(
                    {
                        "error": "Unauthorized",
                        "message": "Authorization header is missing",
                    },
                    status=401,
                )

            # Validate token with Firebase
            try:
                user: AuthenticatedUser = firebase_auth.verify_token(
                    auth_header
                )
                # Attach user to request for use in view
                request.auth_user = user
                request.auth_user_id = user["uid"]

                logger.debug(
                    f"Request authenticated for user: {user['uid']}"
                )

                # Call the original view with authenticated user
                return view_func(request, *args, **kwargs)

            except TokenExpiredError as e:
                logger.warning(f"Token expired: {e}")
                return JsonResponse(
                    {
                        "error": "Unauthorized",
                        "message": "Token has expired",
                    },
                    status=401,
                )

            except InvalidTokenError as e:
                logger.warning(f"Invalid token: {e}")
                return JsonResponse(
                    {
                        "error": "Unauthorized",
                        "message": "Invalid or malformed token",
                    },
                    status=401,
                )

            except FirebaseAuthenticationError as e:
                logger.error(f"Firebase authentication error: {e}")
                return JsonResponse(
                    {
                        "error": "Unauthorized",
                        "message": "Authentication failed",
                    },
                    status=401,
                )

        except Exception as e:
            logger.error(f"Unexpected error in authentication: {e}")
            return JsonResponse(
                {
                    "error": "Internal Server Error",
                    "message": "An unexpected error occurred",
                },
                status=500,
            )

    return wrapper


class FirebaseAuthenticationMiddleware:
    """
    Django middleware to extract and validate Firebase tokens.

    This middleware:
    1. Extracts Firebase ID token from Authorization header
    2. Validates the token (without raising errors)
    3. Attaches authenticated user to request if token is valid
    4. Allows unauthenticated requests to pass through

    To use this middleware, add it to MIDDLEWARE in settings:
        'common.authentication.FirebaseAuthenticationMiddleware',

    Then in views, you can check:
        if hasattr(request, 'auth_user'):
            user = request.auth_user  # User is authenticated
        else:
            # User is not authenticated
    """

    def __init__(self, get_response):
        """Initialize middleware."""
        self.get_response = get_response
        logger.debug("FirebaseAuthenticationMiddleware initialized")

    def __call__(self, request):
        """Process request."""
        try:
            auth_header = request.META.get("HTTP_AUTHORIZATION", "")

            if auth_header:
                try:
                    user: AuthenticatedUser = firebase_auth.verify_token(
                        auth_header
                    )
                    # Attach user to request
                    request.auth_user = user
                    request.auth_user_id = user["uid"]
                    request.is_authenticated = True

                    logger.debug(
                        f"Middleware authenticated user: {user['uid']}"
                    )

                except (
                    InvalidTokenError,
                    TokenExpiredError,
                    FirebaseAuthenticationError,
                ) as e:
                    # Log but don't fail - let views handle unauthenticated requests
                    logger.debug(f"Middleware token validation failed: {e}")
                    request.is_authenticated = False

            else:
                request.is_authenticated = False

        except Exception as e:
            logger.error(f"Unexpected error in middleware: {e}")
            request.is_authenticated = False

        response = self.get_response(request)
        return response
