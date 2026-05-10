"""Reusable API response helpers."""

from rest_framework.response import Response
from rest_framework import status as http_status


def success_response(data=None, message="Success", status_code=http_status.HTTP_200_OK):
    """
    Return a standardized success response.
    
    Args:
        data: Response data payload
        message: Success message
        status_code: HTTP status code (default: 200)
    
    Returns:
        Response object
    """
    return Response(
        {
            "success": True,
            "message": message,
            "data": data
        },
        status=status_code
    )


def error_response(message, status_code=http_status.HTTP_400_BAD_REQUEST, data=None):
    """
    Return a standardized error response.
    
    Args:
        message: Error message
        status_code: HTTP status code (default: 400)
        data: Additional error data (optional)
    
    Returns:
        Response object
    """
    return Response(
        {
            "success": False,
            "message": message,
            "data": data
        },
        status=status_code
    )
