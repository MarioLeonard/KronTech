"""Service layer for completing onboarding profiles."""

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Dict

from apps.core.models import UserProfile
from common.firebase.storage import FirebaseStorageError, FirebaseStorageService
from common.firebase.types import AuthenticatedUser
from common.services.profile_service import ProfileService


class OnboardingValidationError(ValueError):
    """Raised when onboarding payload validation fails."""


@dataclass(frozen=True)
class OnboardingProfileData:
    """Validated onboarding data accepted from the client."""

    first_name: str
    last_name: str
    email: str
    date_of_birth: str
    gender: str
    profile_photo_data_url: str
    country: str
    city: str
    street: str
    accept_privacy_policy: bool

    @classmethod
    def from_payload(cls, payload: Dict[str, Any]) -> "OnboardingProfileData":
        first_name = _required_string(payload, "firstName")
        last_name = _required_string(payload, "lastName")
        email = _required_string(payload, "email").lower()
        date_of_birth = _required_string(payload, "dateOfBirth")
        gender = _required_string(payload, "gender")
        profile_photo_data_url = _optional_string(payload, "profilePhotoDataUrl")
        country = _required_string(payload, "country")
        city = _required_string(payload, "city")
        street = _required_string(payload, "street")
        accept_privacy_policy = payload.get("acceptPrivacyPolicy") is True

        if "@" not in email:
            raise OnboardingValidationError("A valid email is required.")
        if not accept_privacy_policy:
            raise OnboardingValidationError(
                "Privacy policy and terms must be accepted."
            )
        if profile_photo_data_url and not profile_photo_data_url.startswith("data:image/"):
            raise OnboardingValidationError("A valid profile photo is required.")

        return cls(
            first_name=first_name,
            last_name=last_name,
            email=email,
            date_of_birth=date_of_birth,
            gender=gender,
            profile_photo_data_url=profile_photo_data_url,
            country=country,
            city=city,
            street=street,
            accept_privacy_policy=accept_privacy_policy,
        )

    def to_firestore(
        self,
        auth_user: AuthenticatedUser,
        *,
        profile_photo_url: str,
        profile_photo_path: str,
    ) -> Dict[str, Any]:
        now = datetime.now(timezone.utc).isoformat()
        full_name = f"{self.first_name} {self.last_name}".strip()

        return {
            "uid": auth_user.get("uid"),
            "email": self.email,
            "display_name": full_name,
            "email_verified": auth_user.get("email_verified", False),
            "photo_url": profile_photo_url,
            "profilePhotoUrl": profile_photo_url,
            "profilePhotoPath": profile_photo_path,
            "firstName": self.first_name,
            "lastName": self.last_name,
            "dateOfBirth": self.date_of_birth,
            "gender": self.gender,
            "country": self.country,
            "city": self.city,
            "street": self.street,
            "acceptPrivacyPolicy": self.accept_privacy_policy,
            "hasCompletedOnboarding": True,
            "onboardingCompletedAt": now,
            "updated_at": now,
        }


class OnboardingService:
    """Coordinates validated onboarding writes to the authenticated user."""

    @staticmethod
    def complete_onboarding(
        auth_user: AuthenticatedUser,
        payload: Dict[str, Any],
    ) -> UserProfile:
        uid = auth_user.get("uid")
        if not uid:
            raise OnboardingValidationError("Authenticated user is missing.")

        onboarding_data = OnboardingProfileData.from_payload(payload)
        token_email = (auth_user.get("email") or "").strip().lower()
        if token_email and onboarding_data.email != token_email:
            raise OnboardingValidationError(
                "Onboarding email must match the authenticated account."
            )

        profile_photo_url = (auth_user.get("photo_url") or "").strip()
        profile_photo_path = ""
        if onboarding_data.profile_photo_data_url:
            try:
                uploaded_photo = FirebaseStorageService.upload_profile_photo(
                    uid=uid,
                    data_url=onboarding_data.profile_photo_data_url,
                )
            except FirebaseStorageError as error:
                raise OnboardingValidationError(str(error)) from error
            profile_photo_url = uploaded_photo.url
            profile_photo_path = uploaded_photo.path

        if not profile_photo_url:
            raise OnboardingValidationError("A profile photo is required.")

        profile = ProfileService.get_or_create_profile(auth_user)
        profile.update(
            onboarding_data.to_firestore(
                auth_user,
                profile_photo_url=profile_photo_url,
                profile_photo_path=profile_photo_path,
            )
        )
        return profile


def _required_string(payload: Dict[str, Any], field: str) -> str:
    value = payload.get(field)
    if not isinstance(value, str) or not value.strip():
        raise OnboardingValidationError(f"{field} is required.")
    return value.strip()


def _optional_string(payload: Dict[str, Any], field: str) -> str:
    value = payload.get(field)
    if value is None:
        return ""
    if not isinstance(value, str):
        raise OnboardingValidationError(f"{field} must be a string.")
    return value.strip()
