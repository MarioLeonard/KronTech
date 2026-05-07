"""Custom exceptions for Firebase adapters."""


class FirebaseConfigError(Exception):
    """Raised when Firebase configuration is invalid or missing."""

    pass


class InvalidTokenError(Exception):
    """Raised when Firebase ID token is invalid or expired."""

    pass


class TokenExpiredError(InvalidTokenError):
    """Raised when Firebase ID token has expired."""

    pass


class FirebaseAuthenticationError(Exception):
    """Raised when there's an error authenticating with Firebase."""

    pass
