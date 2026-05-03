"""Firebase integration layer."""

from .auth import FirebaseAuthService, firebase_auth
from .exceptions import (
    FirebaseAuthenticationError,
    FirebaseConfigError,
    InvalidTokenError,
    TokenExpiredError,
)
from .types import AuthenticatedUser, FirebaseTokenPayload

__all__ = [
    'firebase_auth',
    'FirebaseAuthService',
    'AuthenticatedUser',
    'FirebaseTokenPayload',
    'FirebaseConfigError',
    'InvalidTokenError',
    'TokenExpiredError',
    'FirebaseAuthenticationError',
]
