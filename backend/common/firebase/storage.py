"""Firebase Cloud Storage integration for file uploads."""

import io
import logging
import mimetypes
from typing import Optional
from datetime import datetime

import firebase_admin
from firebase_admin import storage

logger = logging.getLogger(__name__)


class FirebaseStorageService:
    """Service for Firebase Cloud Storage file operations."""

    _instance = None
    _bucket = None

    def __new__(cls):
        """Implement singleton pattern."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        """Initialize Firebase Storage client."""
        if self._bucket is None:
            self._initialize_storage()

    @staticmethod
    def _initialize_storage():
        """Initialize Firebase Storage bucket."""
        try:
            if not firebase_admin._apps:
                raise Exception("Firebase Admin SDK not initialized")
            FirebaseStorageService._bucket = storage.bucket(
                "krontech-7fbdb.appspot.com"
            )
            logger.info("Firebase Storage client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Storage: {e}")
            raise

    def upload_file(
        self,
        file_path: str,
        file_content: bytes,
        content_type: Optional[str] = None,
    ) -> str:
        """
        Upload a file to Firebase Cloud Storage.

        Args:
            file_path: Path in storage (e.g., "users/uid/profile/photo.jpg")
            file_content: File content as bytes
            content_type: MIME type (auto-detected if not provided)

        Returns:
            Public URL of the uploaded file

        Raises:
            Exception: If upload fails
        """
        try:
            if content_type is None:
                content_type, _ = mimetypes.guess_type(file_path)
                content_type = content_type or "application/octet-stream"

            blob = self._bucket.blob(file_path)
            blob.upload_from_string(
                file_content,
                content_type=content_type,
            )

            # Generate public URL
            public_url = f"https://firebasestorage.googleapis.com/v0/b/{self._bucket.name}/o/{blob.name.replace('/', '%2F')}?alt=media"

            logger.info(f"File uploaded successfully to {file_path}")
            return public_url

        except Exception as e:
            logger.error(f"Failed to upload file to {file_path}: {e}")
            raise Exception(f"File upload failed: {e}")

    def delete_file(self, file_path: str) -> bool:
        """
        Delete a file from Firebase Cloud Storage.

        Args:
            file_path: Path in storage

        Returns:
            True if successful

        Raises:
            Exception: If deletion fails
        """
        try:
            blob = self._bucket.blob(file_path)
            blob.delete()
            logger.info(f"File deleted successfully from {file_path}")
            return True
        except Exception as e:
            logger.error(f"Failed to delete file from {file_path}: {e}")
            raise Exception(f"File deletion failed: {e}")

    def file_exists(self, file_path: str) -> bool:
        """
        Check if a file exists in Firebase Cloud Storage.

        Args:
            file_path: Path in storage

        Returns:
            True if file exists, False otherwise
        """
        try:
            blob = self._bucket.blob(file_path)
            return blob.exists()
        except Exception as e:
            logger.error(f"Failed to check file existence at {file_path}: {e}")
            return False

    def get_file(self, file_path: str) -> Optional[bytes]:
        """
        Download a file from Firebase Cloud Storage.

        Args:
            file_path: Path in storage

        Returns:
            File content as bytes or None if not found

        Raises:
            Exception: If download fails
        """
        try:
            blob = self._bucket.blob(file_path)
            return blob.download_as_bytes()
        except Exception as e:
            logger.error(f"Failed to download file from {file_path}: {e}")
            raise Exception(f"File download failed: {e}")

    @staticmethod
    def generate_storage_path(uid: str, filename: str, category: str = "profile") -> str:
        """
        Generate a unique storage path for a user file.

        Args:
            uid: Firebase UID
            filename: Original filename
            category: File category (e.g., "profile", "documents")

        Returns:
            Path for storage
        """
        # Sanitize filename - keep extension
        import re
        safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', filename)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        return f"users/{uid}/{category}/{timestamp}_{safe_name}"
