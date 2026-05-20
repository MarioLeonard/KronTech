"""In-memory user presence tracking for websocket sessions."""

from django.utils import timezone


class PresenceService:
    """Track online websocket sessions per user in the current ASGI process."""

    _online_counts: dict[str, int] = {}
    _last_seen: dict[str, object] = {}

    @classmethod
    def mark_online(cls, user_id: str) -> dict:
        if not user_id:
            return cls.get_presence(user_id)

        cls._online_counts[user_id] = cls._online_counts.get(user_id, 0) + 1
        return cls.get_presence(user_id)

    @classmethod
    def mark_offline(cls, user_id: str) -> dict:
        if not user_id:
            return cls.get_presence(user_id)

        count = max(cls._online_counts.get(user_id, 0) - 1, 0)
        if count == 0:
            cls._online_counts.pop(user_id, None)
            cls._last_seen[user_id] = timezone.now()
        else:
            cls._online_counts[user_id] = count
        return cls.get_presence(user_id)

    @classmethod
    def get_presence(cls, user_id: str) -> dict:
        is_online = cls._online_counts.get(user_id, 0) > 0
        last_seen = cls._last_seen.get(user_id)
        return {
            "status": "online" if is_online else "offline",
            "last_seen": last_seen.isoformat() if last_seen else None,
        }
