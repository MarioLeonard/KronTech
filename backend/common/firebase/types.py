"""Shared types for Firebase payloads."""

from typing import Any, Dict, Optional, TypedDict


class FirebaseTokenPayload(TypedDict, total=False):
    """Firebase ID token payload structure."""

    iss: str  # Issuer
    aud: str  # Audience (Firebase project ID)
    auth_time: int  # Authentication time (Unix timestamp)
    user_id: str  # Firebase UID
    sub: str  # Subject (usually same as user_id)
    iat: int  # Issued at time
    exp: int  # Expiration time
    firebase: Dict[str, Any]  # Firebase-specific claims
    email: Optional[str]  # User email
    email_verified: bool  # Email verification status
    name: Optional[str]  # User display name
    picture: Optional[str]  # User profile picture
    custom_claims: Dict[str, Any]  # Custom claims


class AuthenticatedUser(TypedDict, total=False):
    """Authenticated user information extracted from Firebase token."""

    uid: str  # Firebase UID
    email: Optional[str]  # User email
    email_verified: bool  # Email verification status
    display_name: Optional[str]  # User display name
    photo_url: Optional[str]  # User profile picture URL
    custom_claims: Dict[str, Any]  # Custom claims from Firebase token
