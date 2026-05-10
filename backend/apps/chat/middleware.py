"""ASGI middleware for Firebase-authenticated chat websocket connections."""

from urllib.parse import parse_qs

from common.firebase.auth import firebase_auth


class FirebaseAuthMiddleware:
    """Attach a Firebase user dict to the websocket scope when a token is valid."""

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        scope = dict(scope)
        token = self._read_token(scope)

        if token:
            try:
                scope["user"] = firebase_auth.verify_token(token)
            except Exception:
                scope["user"] = None
        else:
            scope["user"] = None

        return await self.app(scope, receive, send)

    def _read_token(self, scope):
        headers = {
            key.decode("latin1").lower(): value.decode("latin1")
            for key, value in scope.get("headers", [])
        }
        auth_header = headers.get("authorization")
        if auth_header:
            return auth_header

        query_params = parse_qs(scope.get("query_string", b"").decode())
        token_values = query_params.get("token") or query_params.get("access_token")
        if token_values:
            return token_values[0]

        return None
