from rest_framework import status
from rest_framework.views import APIView

from common.api.responses import error_response, success_response
from common.services.friend_service import (
    FriendService,
    FriendServiceError,
    FriendServiceNotFoundError,
    FriendServicePermissionError,
    FriendServiceValidationError,
)


def _current_user_id(request):
    auth_user = getattr(request, "auth_user", None)
    if isinstance(auth_user, dict):
        return auth_user.get("uid")
    return getattr(request, "auth_user_id", None)


def _require_user_id(request):
    user_id = _current_user_id(request)
    if not user_id:
        return None, error_response(
            "User not authenticated",
            status.HTTP_401_UNAUTHORIZED,
        )
    return user_id, None


def _service_error_response(error):
    if isinstance(error, FriendServiceValidationError):
        return error_response(str(error), status.HTTP_400_BAD_REQUEST)
    if isinstance(error, FriendServicePermissionError):
        return error_response(str(error), status.HTTP_403_FORBIDDEN)
    if isinstance(error, FriendServiceNotFoundError):
        return error_response(str(error), status.HTTP_404_NOT_FOUND)
    return error_response(str(error), status.HTTP_500_INTERNAL_SERVER_ERROR)


class FriendListView(APIView):
    def get(self, request):
        user_id, auth_error = _require_user_id(request)
        if auth_error:
            return auth_error

        page = request.query_params.get("page", "1")
        limit = request.query_params.get("limit", "20")
        try:
            data = FriendService().list_friends(
                user_id,
                page=int(page),
                limit=int(limit),
            )
        except (TypeError, ValueError):
            return error_response("Invalid pagination parameters", status.HTTP_400_BAD_REQUEST)
        except FriendServiceError as error:
            return _service_error_response(error)

        return success_response(data=data, message="Friends retrieved successfully")


class FriendSearchView(APIView):
    def get(self, request):
        user_id, auth_error = _require_user_id(request)
        if auth_error:
            return auth_error

        query = request.query_params.get("q", "")
        limit = request.query_params.get("limit", "20")
        try:
            data = FriendService().search_users(
                user_id,
                query=query,
                limit=int(limit),
            )
        except (TypeError, ValueError):
            return error_response("Invalid search parameters", status.HTTP_400_BAD_REQUEST)
        except FriendServiceError as error:
            return _service_error_response(error)

        return success_response(data=data, message="Users retrieved successfully")


class FriendRequestListCreateView(APIView):
    def get(self, request):
        user_id, auth_error = _require_user_id(request)
        if auth_error:
            return auth_error

        try:
            data = FriendService().list_received_requests(user_id)
        except FriendServiceError as error:
            return _service_error_response(error)

        return success_response(data=data, message="Friend requests retrieved successfully")

    def post(self, request):
        user_id, auth_error = _require_user_id(request)
        if auth_error:
            return auth_error

        receiver_id = (request.data.get("receiver_id") or "").strip()
        try:
            friend_request = FriendService().send_request(user_id, receiver_id)
        except FriendServiceError as error:
            return _service_error_response(error)

        return success_response(
            data={"request": friend_request},
            message="Friend request sent successfully",
            status_code=status.HTTP_201_CREATED,
        )


class FriendRequestAcceptView(APIView):
    def post(self, request, request_id):
        user_id, auth_error = _require_user_id(request)
        if auth_error:
            return auth_error

        try:
            data = FriendService().accept_request(user_id, request_id)
        except FriendServiceError as error:
            return _service_error_response(error)

        return success_response(data=data, message="Friend request accepted")


class FriendRequestDeclineView(APIView):
    def post(self, request, request_id):
        user_id, auth_error = _require_user_id(request)
        if auth_error:
            return auth_error

        try:
            friend_request = FriendService().decline_request(user_id, request_id)
        except FriendServiceError as error:
            return _service_error_response(error)

        return success_response(
            data={"request": friend_request},
            message="Friend request declined",
        )
