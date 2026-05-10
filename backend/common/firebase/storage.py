"""Firebase Cloud Storage integration for file uploads."""

import base64
import binascii
import io
import logging
import mimetypes
from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from urllib.parse import quote
from uuid import uuid4

import firebase_admin
from firebase_admin import storage
from django.conf import settings

logger = logging.getLogger(__name__)


class FirebaseStorageError(Exception):
    """Raised when Firebase Storage validation or upload fails."""


@dataclass(frozen=True)
class UploadedProfilePhoto:
    """Metadata returned after a successful Firebase Storage upload."""

    path: str
    url: str


UploadedStorageFile = UploadedProfilePhoto


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
            bucket_name = getattr(
                settings,
                "FIREBASE_STORAGE_BUCKET",
                "krontech-7fbdb.appspot.com",
            )
            FirebaseStorageService._bucket = storage.bucket(bucket_name)
            logger.info("Firebase Storage client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Storage: {e}")
            raise FirebaseStorageError(f"Storage initialization failed: {e}") from e

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
            FirebaseStorageError: If upload fails
        """
        try:
            if content_type is None:
                content_type, _ = mimetypes.guess_type(file_path)
                content_type = content_type or "application/octet-stream"

            blob = self._bucket.blob(file_path)
            download_token = str(uuid4())
            blob.metadata = {
                **(blob.metadata or {}),
                "firebaseStorageDownloadTokens": download_token,
            }
            blob.upload_from_string(
                file_content,
                content_type=content_type,
            )

            encoded_name = quote(blob.name, safe="")
            public_url = (
                f"https://firebasestorage.googleapis.com/v0/b/{self._bucket.name}"
                f"/o/{encoded_name}?alt=media&token={download_token}"
            )

            logger.info(f"File uploaded successfully to {file_path}")
            return public_url

        except Exception as e:
            logger.error(f"Failed to upload file to {file_path}: {e}")
            raise FirebaseStorageError(f"File upload failed: {e}") from e

    @staticmethod
    def upload_profile_photo(uid: str, data_url: str) -> UploadedProfilePhoto:
        """
        Upload a base64 data URL profile photo to Firebase Cloud Storage.

        Args:
            uid: Firebase UID
            data_url: Image data URL from the client

        Returns:
            Uploaded file metadata including URL and storage path

        Raises:
            FirebaseStorageError: If validation or upload fails
        """
        content_type, file_content = FirebaseStorageService._parse_image_data_url(
            data_url
        )
        extension = FirebaseStorageService._extension_for_content_type(content_type)
        filename = f"profile_photo.{extension}"

        storage_service = FirebaseStorageService()
        storage_path = storage_service.generate_storage_path(
            uid,
            filename,
            "profile",
        )
        url = storage_service.upload_file(
            storage_path,
            file_content,
            content_type,
        )

        return UploadedProfilePhoto(path=storage_path, url=url)

    @staticmethod
    def _parse_image_data_url(data_url: str) -> tuple:
        """Decode and validate an image data URL."""
        if not data_url or not isinstance(data_url, str):
            raise FirebaseStorageError("Profile photo is required.")

        header, separator, encoded_data = data_url.partition(",")
        if separator != "," or not header.startswith("data:image/"):
            raise FirebaseStorageError("Invalid profile photo data URL.")
        if ";base64" not in header:
            raise FirebaseStorageError("Profile photo must be base64 encoded.")

        content_type = header[5:].split(";", 1)[0].lower()
        allowed_types = {"image/jpeg", "image/png", "image/webp", "image/gif"}
        if content_type not in allowed_types:
            raise FirebaseStorageError(
                f"Invalid file type. Allowed types: {', '.join(sorted(allowed_types))}"
            )

        try:
            file_content = base64.b64decode(encoded_data, validate=True)
        except (binascii.Error, ValueError) as e:
            raise FirebaseStorageError("Invalid profile photo encoding.") from e

        if not file_content:
            raise FirebaseStorageError("Profile photo is empty.")

        max_size = 5 * 1024 * 1024
        if len(file_content) > max_size:
            raise FirebaseStorageError("File size exceeds 5MB limit.")

        return content_type, file_content

    @staticmethod
    def _extension_for_content_type(content_type: str) -> str:
        """Return a stable file extension for supported image MIME types."""
        return {
            "image/jpeg": "jpg",
            "image/png": "png",
            "image/webp": "webp",
            "image/gif": "gif",
        }[content_type]

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
