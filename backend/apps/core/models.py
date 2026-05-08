"""Core models for the application."""

from typing import Optional

from django.db import models

from common.firebase.database import FirestoreService


class UserProfile:
    """
    User profile model that syncs data from Firestore.

    This model represents user profile data stored in Firestore,
    providing methods to fetch, create, and update user profiles.
    """

    COLLECTION = "users"

    def __init__(self, uid: str, data: Optional[dict] = None):
        """
        Initialize a user profile.

        Args:
            uid: Firebase UID
            data: User profile data from Firestore
        """
        self.uid = uid
        self.data = data or {}
        self._load_data()

    def _load_data(self):
        """Load user data from Firestore if not provided."""
        if not self.data and self.uid:
            firestore = FirestoreService()
            self.data = firestore.get_document(self.COLLECTION, self.uid) or {}

    @property
    def email(self) -> Optional[str]:
        """Get user email."""
        return self.data.get("email")

    @property
    def display_name(self) -> Optional[str]:
        """Get user display name."""
        return self.data.get("display_name")

    @property
    def photo_url(self) -> Optional[str]:
        """Get user profile picture URL."""
        return self.data.get("photo_url")

    @property
    def bio(self) -> Optional[str]:
        """Get user bio."""
        return self.data.get("bio")

    @property
    def location(self) -> Optional[str]:
        """Get user location."""
        return self.data.get("location")

    @property
    def created_at(self) -> Optional[str]:
        """Get account creation timestamp."""
        return self.data.get("created_at")

    @property
    def updated_at(self) -> Optional[str]:
        """Get profile last update timestamp."""
        return self.data.get("updated_at")

    @property
    def first_name(self) -> Optional[str]:
        """Get user first name."""
        return self.data.get("firstName")

    @property
    def last_name(self) -> Optional[str]:
        """Get user last name."""
        return self.data.get("lastName")

    @property
    def date_of_birth(self) -> Optional[str]:
        """Get user date of birth."""
        return self.data.get("dateOfBirth")

    @property
    def gender(self) -> Optional[str]:
        """Get user gender."""
        return self.data.get("gender")

    @property
    def country(self) -> Optional[str]:
        """Get user country."""
        return self.data.get("country")

    @property
    def city(self) -> Optional[str]:
        """Get user city."""
        return self.data.get("city")

    @property
    def street(self) -> Optional[str]:
        """Get user street address."""
        return self.data.get("street")

    @property
    def profile_photo_url(self) -> Optional[str]:
        """Get user profile photo URL from Storage."""
        return self.data.get("profilePhotoUrl")

    @classmethod
    def from_firebase_user(cls, uid: str, auth_user: dict):
        """
        Create a user profile from Firebase authentication data.

        Args:
            uid: Firebase UID
            auth_user: Authenticated user data from Firebase token

        Returns:
            UserProfile instance
        """
        profile_data = {
            "uid": uid,
            "email": auth_user.get("email"),
            "display_name": auth_user.get("display_name"),
            "photo_url": auth_user.get("photo_url"),
            "email_verified": auth_user.get("email_verified", False),
        }
        return cls(uid, profile_data)

    def to_dict(self) -> dict:
        """
        Convert profile to dictionary.

        Returns:
            Profile data as dictionary
        """
        return {
            "uid": self.uid,
            **self.data,
        }

    def update(self, data: dict) -> bool:
        """
        Update user profile in Firestore.

        Args:
            data: Fields to update

        Returns:
            True if successful
        """
        try:
            firestore = FirestoreService()
            firestore.update_document(self.COLLECTION, self.uid, data)
            self.data.update(data)
            return True
        except Exception as e:
            raise Exception(f"Failed to update user profile: {e}")

    def save(self) -> bool:
        """
        Save user profile to Firestore.

        Returns:
            True if successful
        """
        try:
            firestore = FirestoreService()
            firestore.set_document(self.COLLECTION, self.uid, self.data)
            return True
        except Exception as e:
            raise Exception(f"Failed to save user profile: {e}")

    @classmethod
    def get_by_uid(cls, uid: str) -> Optional["UserProfile"]:
        """
        Get user profile by UID.

        Args:
            uid: Firebase UID

        Returns:
            UserProfile instance or None if not found
        """
        try:
            firestore = FirestoreService()
            data = firestore.get_document(cls.COLLECTION, uid)
            if data:
                return cls(uid, data)
            return None
        except Exception as e:
            raise Exception(f"Failed to get user profile: {e}")

    @classmethod
    def get_by_email(cls, email: str) -> Optional["UserProfile"]:
        """
        Get user profile by email.

        Args:
            email: User email

        Returns:
            UserProfile instance or None if not found
        """
        try:
            firestore = FirestoreService()
            results = firestore.get_documents(
                cls.COLLECTION,
                filters=[("email", "==", email)],
                limit=1,
            )
            if results:
                return cls(results[0].get("uid"), results[0])
            return None
        except Exception as e:
            raise Exception(f"Failed to get user profile by email: {e}")
