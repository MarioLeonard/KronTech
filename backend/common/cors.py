"""Small CORS middleware for local frontend-to-backend development."""

from django.conf import settings
from django.http import HttpResponse


class CorsMiddleware:
    """Allow configured frontend origins to call the Django API."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.method == "OPTIONS":
            response = HttpResponse(status=204)
        else:
            response = self.get_response(request)

        origin = request.headers.get("Origin") or request.META.get(
            "HTTP_ORIGIN"
        )
        if self._is_allowed_origin(origin):
            response["Access-Control-Allow-Origin"] = origin
            response["Access-Control-Allow-Credentials"] = "true"
            response["Access-Control-Allow-Headers"] = (
                "Authorization, Content-Type"
            )
            response["Access-Control-Allow-Methods"] = (
                "GET, POST, PUT, PATCH, DELETE, OPTIONS"
            )
            response["Vary"] = "Origin"

        return response

    @staticmethod
    def _is_allowed_origin(origin):
        if not origin:
            return False

        allowed_origins = getattr(settings, "CORS_ALLOWED_ORIGINS", [])
        if origin in allowed_origins:
            return True

        if settings.DEBUG and (
            origin.startswith("http://localhost:")
            or origin.startswith("http://127.0.0.1:")
        ):
            return True

        return False
