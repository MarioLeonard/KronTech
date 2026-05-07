"""Firebase Storage integration for user-uploaded media."""

import base64
import re
from dataclasses import dataclass
from typing import Tuple
from urllib.parse import quote
from uuid import uuid4

from django.conf import settings
from firebase_admin import storage


class FirebaseStorageError(ValueError):
    """Raised when a Firebase Storage upload cannot be completed."""


@dataclass(frozen=True)
class UploadedProfilePhoto:
    """Result of a profile photo upload."""

    url: str
    path: str


class FirebaseStorageService:
    """Service for writing profile media to Firebase Storage."""

    _allowed_content_types = {
        "image/jpeg": "jpg",
        "image/png": "png",
        "image/webp": "webp",
    }
    _data_url_pattern = re.compile(r"^data:(image/[a-zA-Z0-9.+-]+);base64,(.+)$")
    _max_profile_photo_bytes = 2 * 1024 * 1024

    @classmethod
    def upload_profile_photo(
        cls,
        *,
        uid: str,
        data_url: str,
    ) -> UploadedProfilePhoto:
        content_type, image_bytes = cls._decode_image_data_url(data_url)
        extension = cls._allowed_content_types[content_type]
        token = str(uuid4())
        path = f"users/{uid}/profile/profile-photo.{extension}"

        bucket = storage.bucket(getattr(settings, "FIREBASE_STORAGE_BUCKET"))
        blob = bucket.blob(path)
        blob.metadata = {"firebaseStorageDownloadTokens": token}
        blob.upload_from_string(image_bytes, content_type=content_type)
        blob.patch()

        encoded_path = quote(path, safe="")
        url = (
            f"https://firebasestorage.googleapis.com/v0/b/{bucket.name}/o/"
            f"{encoded_path}?alt=media&token={token}"
        )
        return UploadedProfilePhoto(url=url, path=path)

    @classmethod
    def _decode_image_data_url(cls, data_url: str) -> Tuple[str, bytes]:
        match = cls._data_url_pattern.match(data_url.strip())
        if not match:
            raise FirebaseStorageError("A valid profile photo is required.")

        content_type = match.group(1).lower()
        if content_type not in cls._allowed_content_types:
            raise FirebaseStorageError(
                "Profile photo must be a JPG, PNG, or WEBP image."
            )

        try:
            image_bytes = base64.b64decode(match.group(2), validate=True)
        except Exception as error:
            raise FirebaseStorageError("Profile photo data is invalid.") from error

        if not image_bytes:
            raise FirebaseStorageError("Profile photo cannot be empty.")
        if len(image_bytes) > cls._max_profile_photo_bytes:
            raise FirebaseStorageError("Profile photo must be 2MB or smaller.")

        return content_type, image_bytes
