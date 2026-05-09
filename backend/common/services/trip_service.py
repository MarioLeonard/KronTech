"""Service layer for trip operations."""

import logging
import uuid
from typing import Optional, List
from datetime import datetime

from apps.core.models import Trip
from common.firebase.types import AuthenticatedUser

logger = logging.getLogger(__name__)


class TripService:
    """Service for managing trips."""

    # Whitelisted fields that can be updated via API
    ALLOWED_UPDATE_FIELDS = {
        "startLocation",
        "destination",
        "waypoints",
        "dateTime",
        "distance",
        "duration",
        "status",
    }

    VALID_STATUSES = {"planned", "in_progress", "completed", "cancelled"}

    @staticmethod
    def validate_location(location: dict, field_name: str = "location") -> bool:
        """
        Validate a location object.

        Args:
            location: Location dict with required fields
            field_name: Name of field for error messages

        Returns:
            True if valid

        Raises:
            ValueError: If location is invalid
        """
        if not isinstance(location, dict):
            raise ValueError(f"{field_name} must be a dictionary")

        required_fields = {"latitude", "longitude", "address"}
        missing = required_fields - set(location.keys())
        if missing:
            raise ValueError(
                f"{field_name} missing required fields: {', '.join(missing)}"
            )

        # Validate coordinates
        try:
            lat = float(location.get("latitude"))
            lon = float(location.get("longitude"))
            
            if not (-90 <= lat <= 90):
                raise ValueError(
                    f"{field_name} latitude must be between -90 and 90"
                )
            if not (-180 <= lon <= 180):
                raise ValueError(
                    f"{field_name} longitude must be between -180 and 180"
                )
        except (TypeError, ValueError) as e:
            raise ValueError(f"{field_name} coordinates invalid: {e}")

        # Validate address
        address = location.get("address")
        if not address or not isinstance(address, str) or len(address.strip()) == 0:
            raise ValueError(f"{field_name} address must be a non-empty string")

        return True

    @staticmethod
    def validate_waypoints(waypoints: list) -> bool:
        """
        Validate waypoints list.

        Args:
            waypoints: List of waypoint objects

        Returns:
            True if valid

        Raises:
            ValueError: If waypoints are invalid
        """
        if not isinstance(waypoints, list):
            raise ValueError("waypoints must be a list")

        for i, waypoint in enumerate(waypoints):
            try:
                TripService.validate_location(waypoint, f"waypoint[{i}]")
            except ValueError as e:
                raise ValueError(str(e))

        return True

    @staticmethod
    def validate_date_time(date_time: str) -> bool:
        """
        Validate trip date and time.

        Args:
            date_time: ISO format datetime string

        Returns:
            True if valid

        Raises:
            ValueError: If datetime is invalid
        """
        if not date_time or not isinstance(date_time, str):
            raise ValueError("dateTime must be a non-empty string")

        try:
            dt = datetime.fromisoformat(date_time.replace("Z", "+00:00"))
            # Check it's not in the past
            now = datetime.now(dt.tzinfo) if dt.tzinfo else datetime.now()
            if dt < now:
                raise ValueError("dateTime cannot be in the past")
        except ValueError as e:
            raise ValueError(f"dateTime must be ISO format: {e}")

        return True

    @staticmethod
    def validate_status(status: str) -> bool:
        """
        Validate trip status.

        Args:
            status: Status value

        Returns:
            True if valid

        Raises:
            ValueError: If status is invalid
        """
        if status not in TripService.VALID_STATUSES:
            raise ValueError(
                f"status must be one of: {', '.join(TripService.VALID_STATUSES)}"
            )
        return True

    @staticmethod
    def create_trip(
        owner_uid: str,
        start_location: dict,
        destination: dict,
        date_time: str,
        waypoints: Optional[list] = None,
        distance: Optional[float] = None,
        duration: Optional[str] = None,
        status: str = "planned",
    ) -> Trip:
        """
        Create a new trip.

        Args:
            owner_uid: UID of trip owner
            start_location: Starting location with latitude, longitude, address
            destination: Destination with latitude, longitude, address
            date_time: ISO format datetime
            waypoints: Optional list of intermediate waypoints
            distance: Optional trip distance in km
            duration: Optional estimated duration
            status: Trip status (planned/in_progress/completed/cancelled)

        Returns:
            Created Trip instance

        Raises:
            ValueError: If validation fails
        """
        # Validate required fields
        if not owner_uid:
            raise ValueError("owner_uid is required")

        TripService.validate_location(start_location, "startLocation")
        TripService.validate_location(destination, "destination")
        TripService.validate_date_time(date_time)
        TripService.validate_status(status)

        if waypoints is None:
            waypoints = []
        elif waypoints:
            TripService.validate_waypoints(waypoints)

        # Validate optional numeric fields
        if distance is not None:
            try:
                distance = float(distance)
                if distance < 0:
                    raise ValueError("distance cannot be negative")
            except (TypeError, ValueError):
                raise ValueError("distance must be a positive number")

        # Generate unique trip ID
        trip_id = str(uuid.uuid4())
        now = datetime.utcnow().isoformat() + "Z"

        trip_data = {
            "id": trip_id,
            "ownerUid": owner_uid,
            "startLocation": start_location,
            "destination": destination,
            "waypoints": waypoints,
            "dateTime": date_time,
            "distance": distance,
            "duration": duration,
            "status": status,
            "createdAt": now,
            "updatedAt": now,
        }

        trip = Trip(trip_id, trip_data)
        trip.save()

        logger.info(f"Created trip {trip_id} for user {owner_uid}")
        return trip

    @staticmethod
    def get_user_trips(owner_uid: str) -> List[Trip]:
        """
        Get all trips for a user.

        Args:
            owner_uid: User's Firebase UID

        Returns:
            List of Trip instances

        Raises:
            Exception: If retrieval fails
        """
        return Trip.get_by_owner(owner_uid)

    @staticmethod
    def get_trip(trip_id: str, owner_uid: str) -> Optional[Trip]:
        """
        Get a specific trip with ownership validation.

        Args:
            trip_id: Trip ID
            owner_uid: Current user's UID (for authorization)

        Returns:
            Trip instance or None if not found

        Raises:
            PermissionError: If user doesn't own the trip
        """
        trip = Trip.get_by_id(trip_id)

        if not trip:
            return None

        if trip.owner_uid != owner_uid:
            raise PermissionError(
                f"User {owner_uid} does not have access to trip {trip_id}"
            )

        return trip

    @staticmethod
    def update_trip(
        trip_id: str,
        owner_uid: str,
        data: dict,
    ) -> Trip:
        """
        Update a trip with ownership validation.

        Args:
            trip_id: Trip ID
            owner_uid: Current user's UID (must be trip owner)
            data: Fields to update

        Returns:
            Updated Trip instance

        Raises:
            PermissionError: If user doesn't own the trip
            ValueError: If validation fails
        """
        trip = Trip.get_by_id(trip_id)

        if not trip:
            raise ValueError(f"Trip {trip_id} not found")

        if trip.owner_uid != owner_uid:
            raise PermissionError(
                f"User {owner_uid} cannot modify trip {trip_id}"
            )

        # Filter to only allowed fields
        filtered_data = {
            k: v for k, v in data.items()
            if k in TripService.ALLOWED_UPDATE_FIELDS
        }

        # Check for non-allowed fields
        non_allowed = set(data.keys()) - TripService.ALLOWED_UPDATE_FIELDS
        if non_allowed:
            logger.warning(
                f"User {owner_uid} attempted to update non-allowed fields: {non_allowed}"
            )

        # Validate specific fields if present
        if "startLocation" in filtered_data:
            TripService.validate_location(
                filtered_data["startLocation"], "startLocation"
            )

        if "destination" in filtered_data:
            TripService.validate_location(
                filtered_data["destination"], "destination"
            )

        if "waypoints" in filtered_data:
            if filtered_data["waypoints"]:
                TripService.validate_waypoints(filtered_data["waypoints"])

        if "dateTime" in filtered_data:
            TripService.validate_date_time(filtered_data["dateTime"])

        if "status" in filtered_data:
            TripService.validate_status(filtered_data["status"])

        if "distance" in filtered_data and filtered_data["distance"] is not None:
            try:
                distance = float(filtered_data["distance"])
                if distance < 0:
                    raise ValueError("distance cannot be negative")
                filtered_data["distance"] = distance
            except (TypeError, ValueError):
                raise ValueError("distance must be a positive number")

        # Add updated timestamp
        filtered_data["updatedAt"] = datetime.utcnow().isoformat() + "Z"

        if filtered_data:
            trip.update(filtered_data)
            logger.info(f"Updated trip {trip_id} for user {owner_uid}")

        return trip

    @staticmethod
    def delete_trip(trip_id: str, owner_uid: str) -> bool:
        """
        Delete a trip with ownership validation.

        Args:
            trip_id: Trip ID
            owner_uid: Current user's UID (must be trip owner)

        Returns:
            True if successful

        Raises:
            PermissionError: If user doesn't own the trip
            ValueError: If trip not found
        """
        trip = Trip.get_by_id(trip_id)

        if not trip:
            raise ValueError(f"Trip {trip_id} not found")

        if trip.owner_uid != owner_uid:
            raise PermissionError(
                f"User {owner_uid} cannot delete trip {trip_id}"
            )

        trip.delete()
        logger.info(f"Deleted trip {trip_id} for user {owner_uid}")
        return True
