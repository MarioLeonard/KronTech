"""Firebase Auth integration placeholders."""

import logging
from typing import Optional

import firebase_admin
from firebase_admin import auth, credentials
from django.conf import settings

from .exceptions import (
    FirebaseAuthenticationError,
    FirebaseConfigError,
    InvalidTokenError,
    TokenExpiredError,
)
from .types import AuthenticatedUser, FirebaseTokenPayload

logger = logging.getLogger(__name__)


class FirebaseAuthService:
    """Service for validating Firebase ID tokens and managing authentication."""

    _instance = None
    _initialized = False

    def __new__(cls):
        """Implement singleton pattern."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        """Initialize Firebase Admin SDK."""
        if not self._initialized:
            self._initialize_firebase()
            self.__class__._initialized = True

    @staticmethod
    def _initialize_firebase():
        """Initialize Firebase Admin SDK with credentials."""
        # Check if Firebase is already initialized
        if firebase_admin._apps:
            logger.info("Firebase Admin SDK already initialized")
            return

        firebase_creds_path = getattr(
            settings, "FIREBASE_CREDENTIALS_PATH", None
        )

        if not firebase_creds_path:
            raise FirebaseConfigError(
                "FIREBASE_CREDENTIALS_PATH not set in Django settings. "
                "Please provide path to Firebase service account key JSON file."
            )

        try:
            cred = credentials.Certificate(firebase_creds_path)
            firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin SDK initialized successfully")
        except FileNotFoundError as e:
            raise FirebaseConfigError(
                f"Firebase credentials file not found at {firebase_creds_path}: {e}"
            )
        except Exception as e:
            raise FirebaseConfigError(
                f"Failed to initialize Firebase Admin SDK: {e}"
            )

    @staticmethod
    def verify_token(token: str) -> AuthenticatedUser:
        """
        Verify Firebase ID token and extract user information.

        Args:
            token: Firebase ID token from client

        Returns:
            AuthenticatedUser: User information extracted from token

        Raises:
            InvalidTokenError: If token is invalid or verification fails
            TokenExpiredError: If token has expired
            FirebaseAuthenticationError: If Firebase authentication fails
        """
        if not token:
            raise InvalidTokenError("No token provided")

        try:
            # Remove 'Bearer ' prefix if present
            if token.startswith("Bearer "):
                token = token[7:]

            # Verify and decode token
            decoded_token = auth.verify_id_token(token)

            # Extract user information
            user_info: AuthenticatedUser = {
                "uid": decoded_token.get("uid", ""),
                "email": decoded_token.get("email"),
                "email_verified": decoded_token.get("email_verified", False),
                "display_name": decoded_token.get("name"),
                "photo_url": decoded_token.get("picture"),
                "custom_claims": decoded_token.get("custom_claims", {}),
            }

            logger.debug(
                f"Token verified successfully for user: {user_info['uid']}"
            )
            return user_info

        except auth.ExpiredSignatureError as e:
            logger.warning(f"Expired token verification failed: {e}")
            raise TokenExpiredError(f"Token has expired: {e}")
        except auth.InvalidIdTokenError as e:
            logger.warning(f"Invalid token verification failed: {e}")
            raise InvalidTokenError(f"Invalid or malformed token: {e}")
        except auth.InvalidSignatureError as e:
            logger.warning(f"Invalid signature verification failed: {e}")
            raise InvalidTokenError(f"Invalid token signature: {e}")
        except auth.FirebaseError as e:
            logger.error(f"Firebase authentication error: {e}")
            raise FirebaseAuthenticationError(
                f"Firebase authentication failed: {e}"
            )
        except Exception as e:
            logger.error(f"Unexpected error during token verification: {e}")
            raise FirebaseAuthenticationError(
                f"Unexpected error during authentication: {e}"
            )

    @staticmethod
    def get_user(uid: str) -> Optional[dict]:
        """
        Get user information from Firebase by UID.

        Args:
            uid: Firebase user UID

        Returns:
            User record dict or None if not found
        """
        try:
            user_record = auth.get_user(uid)
            return {
                "uid": user_record.uid,
                "email": user_record.email,
                "email_verified": user_record.email_verified,
                "display_name": user_record.display_name,
                "photo_url": user_record.photo_url,
                "disabled": user_record.disabled,
            }
        except auth.UserNotFoundError:
            logger.warning(f"User not found: {uid}")
            return None
        except Exception as e:
            logger.error(f"Error retrieving user {uid}: {e}")
            return None


# Singleton instance
firebase_auth = FirebaseAuthService()
