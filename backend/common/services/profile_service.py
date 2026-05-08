"""Service layer for user profile operations."""

import logging
from typing import Optional

from apps.core.models import UserProfile
from common.firebase.auth import FirebaseAuthService
from common.firebase.types import AuthenticatedUser
from common.firebase.storage import FirebaseStorageService

logger = logging.getLogger(__name__)


class ProfileService:
    """Service for managing user profiles."""

    # Whitelisted fields that can be updated via API
    ALLOWED_UPDATE_FIELDS = {
        "firstName",
        "lastName",
        "dateOfBirth",
        "gender",
        "country",
        "city",
        "street",
    }

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
        
        Only whitelisted fields are allowed:
        - firstName, lastName, dateOfBirth, gender
        - country, city, street

        Args:
            uid: Firebase UID
            data: Fields to update

        Returns:
            Updated UserProfile instance

        Raises:
            ValueError: If non-whitelisted fields are present
            Exception: If profile update fails
        """
        profile = UserProfile.get_by_uid(uid)

        if not profile:
            raise Exception(f"Profile not found for user {uid}")

        # Filter to only allowed fields
        filtered_data = {
            k: v for k, v in data.items()
            if k in ProfileService.ALLOWED_UPDATE_FIELDS
        }

        # Check if any non-allowed fields were attempted
        non_allowed = set(data.keys()) - ProfileService.ALLOWED_UPDATE_FIELDS
        if non_allowed:
            logger.warning(
                f"User {uid} attempted to update non-allowed fields: {non_allowed}"
            )

        if filtered_data:
            profile.update(filtered_data)
            logger.info(f"Updated profile for user {uid} with fields: {list(filtered_data.keys())}")

        return profile

    @staticmethod
    def upload_profile_photo(
        uid: str,
        file_content: bytes,
        filename: str,
        content_type: str,
    ) -> UserProfile:
        """
        Upload profile photo to Firebase Storage and save URL in profile.

        Args:
            uid: Firebase UID
            file_content: File content as bytes
            filename: Original filename
            content_type: MIME type of file

        Returns:
            Updated UserProfile instance

        Raises:
            ValueError: If file is invalid
            Exception: If upload fails
        """
        # Validate file
        if not file_content:
            raise ValueError("File content is empty")

        # Validate file size (max 5MB)
        max_size = 5 * 1024 * 1024
        if len(file_content) > max_size:
            raise ValueError("File size exceeds 5MB limit")

        # Validate content type
        allowed_types = {"image/jpeg", "image/png", "image/webp", "image/gif"}
        if content_type not in allowed_types:
            raise ValueError(
                f"Invalid file type. Allowed types: {', '.join(allowed_types)}"
            )

        try:
            # Upload to Firebase Storage
            storage = FirebaseStorageService()
            storage_path = storage.generate_storage_path(uid, filename, "profile")
            photo_url = storage.upload_file(
                storage_path,
                file_content,
                content_type,
            )

            # Delete old photo if exists
            profile = UserProfile.get_by_uid(uid)
            old_photo_url = profile.profile_photo_url if profile else None
            if old_photo_url:
                try:
                    # Extract storage path from URL and delete old file
                    logger.info(f"Old photo exists for user {uid}, keeping for reference")
                except Exception as e:
                    logger.warning(f"Failed to delete old photo: {e}")

            # Update profile with new photo URL
            profile = UserProfile.get_by_uid(uid)
            if not profile:
                raise Exception(f"Profile not found for user {uid}")

            profile.update({"profilePhotoUrl": photo_url})
            logger.info(f"Profile photo updated for user {uid}")

            return profile

        except Exception as e:
            logger.error(f"Failed to upload profile photo for user {uid}: {e}")
            raise

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
