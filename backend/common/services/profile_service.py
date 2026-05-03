"""Service layer for user profile operations."""

import logging
from typing import Optional

from apps.core.models import UserProfile
from common.firebase.auth import FirebaseAuthService
from common.firebase.types import AuthenticatedUser

logger = logging.getLogger(__name__)


class ProfileService:
    """Service for managing user profiles."""

    @staticmethod
    def get_or_create_profile(auth_user: AuthenticatedUser) -> UserProfile:
        """
        Get existing user profile or create a new one from Firebase auth data.

        Args:
            auth_user: Authenticated user data from Firebase token

        Returns:
            UserProfile instance

        Raises:
            Exception: If profile creation fails
        """
        uid = auth_user.get("uid")

        # Try to get existing profile
        profile = UserProfile.get_by_uid(uid)

        if profile:
            logger.info(f"Retrieved existing profile for user {uid}")
            return profile

        # Create new profile from auth data
        logger.info(f"Creating new profile for user {uid}")
        profile = UserProfile.from_firebase_user(uid, auth_user)
        profile.save()

        return profile

    @staticmethod
    def update_profile(
        uid: str,
        data: dict,
    ) -> UserProfile:
        """
        Update user profile with new data.

        Args:
            uid: Firebase UID
            data: Fields to update

        Returns:
            Updated UserProfile instance

        Raises:
            Exception: If profile update fails
        """
        profile = UserProfile.get_by_uid(uid)

        if not profile:
            raise Exception(f"Profile not found for user {uid}")

        profile.update(data)
        logger.info(f"Updated profile for user {uid}")

        return profile

    @staticmethod
    def get_profile(uid: str) -> Optional[UserProfile]:
        """
        Get user profile by UID.

        Args:
            uid: Firebase UID

        Returns:
            UserProfile instance or None if not found
        """
        return UserProfile.get_by_uid(uid)

    @staticmethod
    def get_profile_by_email(email: str) -> Optional[UserProfile]:
        """
        Get user profile by email.

        Args:
            email: User email

        Returns:
            UserProfile instance or None if not found
        """
        return UserProfile.get_by_email(email)

    @staticmethod
    def delete_profile(uid: str) -> bool:
        """
        Delete user profile from Firestore.

        Args:
            uid: Firebase UID

        Returns:
            True if successful

        Raises:
            Exception: If profile deletion fails
        """
        try:
            from common.firebase.database import FirestoreService

            firestore = FirestoreService()
            firestore.delete_document(UserProfile.COLLECTION, uid)
            logger.info(f"Deleted profile for user {uid}")
            return True
        except Exception as e:
            logger.error(f"Failed to delete profile for user {uid}: {e}")
            raise
