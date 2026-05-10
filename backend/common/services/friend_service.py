import hashlib
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Dict, Iterable, List, Optional

from google.cloud.firestore_v1.base_query import FieldFilter

from common.firebase.database import FirestoreService


class FriendServiceError(Exception):
    pass


class FriendServiceValidationError(FriendServiceError):
    pass


class FriendServicePermissionError(FriendServiceError):
    pass


class FriendServiceNotFoundError(FriendServiceError):
    pass


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _normalize_text(value: object) -> str:
    return str(value or "").strip().lower()


def _stable_friendship_id(user_id_1: str, user_id_2: str) -> str:
    user_ids = sorted([user_id_1, user_id_2])
    digest = hashlib.sha256("|".join(user_ids).encode("utf-8")).hexdigest()
    return f"friendship_{digest[:32]}"


def _profile_summary(data: Optional[dict], user_id: str) -> dict:
    data = data or {}
    name = (
        data.get("display_name")
        or " ".join(
            part for part in [data.get("firstName"), data.get("lastName")] if part
        ).strip()
        or data.get("email")
        or user_id
    )
    return {
        "id": user_id,
        "uid": user_id,
        "name": name,
        "email": data.get("email"),
        "avatar_url": data.get("profilePhotoUrl") or data.get("photo_url"),
    }


@dataclass
class FriendSearchResult:
    user: dict
    relationship_status: str


class FirestoreFriendRepository:
    def __init__(self):
        self._db = FirestoreService()._db

    def get_user(self, user_id: str) -> Optional[dict]:
        doc = self._db.collection("users").document(user_id).get()
        if not doc.exists:
            return None
        return {"id": doc.id, **doc.to_dict()}

    def search_users(self, query: str, limit: int) -> List[dict]:
        # Firestore has no native contains/full-text search. We intentionally
        # fetch a bounded slice and filter in the service for a pragmatic MVP.
        docs = self._db.collection("users").limit(max(limit * 5, 50)).stream()
        return [{"id": doc.id, **doc.to_dict()} for doc in docs]

    def list_friend_refs(self, user_id: str, page: int, limit: int) -> List[dict]:
        offset = max(page - 1, 0) * limit
        docs = (
            self._db.collection("users")
            .document(user_id)
            .collection("friends")
            .order_by("created_at")
            .offset(offset)
            .limit(limit)
            .stream()
        )
        return [{"id": doc.id, **doc.to_dict()} for doc in docs]

    def find_pending_request(self, sender_id: str, receiver_id: str) -> Optional[dict]:
        # Query one indexed field and filter the rest locally to avoid requiring
        # a composite Firestore index for duplicate checks.
        docs = (
            self._db.collection("friend_requests")
            .where(filter=FieldFilter("sender_id", "==", sender_id))
            .stream()
        )
        for doc in docs:
            data = doc.to_dict()
            if data.get("receiver_id") == receiver_id and data.get("status") == "pending":
                return {"id": doc.id, **data}
        return None

    def get_request(self, request_id: str) -> Optional[dict]:
        doc = self._db.collection("friend_requests").document(request_id).get()
        if not doc.exists:
            return None
        return {"id": doc.id, **doc.to_dict()}

    def list_received_requests(self, user_id: str) -> List[dict]:
        # Keep this index-light for local/dev projects. Filtering by receiver_id
        # uses Firestore's single-field index; pending filter and ordering are
        # applied in Python to avoid requiring a composite index before the
        # feature can run.
        docs = (
            self._db.collection("friend_requests")
            .where(filter=FieldFilter("receiver_id", "==", user_id))
            .stream()
        )
        requests = []
        for doc in docs:
            data = doc.to_dict()
            if data.get("status") == "pending":
                requests.append({"id": doc.id, **data})
        return sorted(
            requests,
            key=lambda request: request.get("created_at") or "",
        )

    def create_request(self, data: dict) -> dict:
        request_id = data["id"]
        self._db.collection("friend_requests").document(request_id).set(data)
        return data

    def update_request(self, request_id: str, data: dict) -> dict:
        self._db.collection("friend_requests").document(request_id).update(data)
        request_data = self.get_request(request_id) or {"id": request_id}
        return request_data

    def get_friendship(self, friendship_id: str) -> Optional[dict]:
        doc = self._db.collection("friendships").document(friendship_id).get()
        if not doc.exists:
            return None
        return {"id": doc.id, **doc.to_dict()}

    def create_friendship(self, friendship: dict, request_id: str) -> dict:
        user_id_1, user_id_2 = friendship["user_ids"]
        batch = self._db.batch()
        friendship_ref = self._db.collection("friendships").document(friendship["id"])
        request_ref = self._db.collection("friend_requests").document(request_id)
        user_1_friend_ref = (
            self._db.collection("users")
            .document(user_id_1)
            .collection("friends")
            .document(user_id_2)
        )
        user_2_friend_ref = (
            self._db.collection("users")
            .document(user_id_2)
            .collection("friends")
            .document(user_id_1)
        )

        batch.set(friendship_ref, friendship, merge=True)
        batch.update(
            request_ref,
            {
                "status": "accepted",
                "updated_at": friendship["created_at"],
                "friendship_id": friendship["id"],
            },
        )
        batch.set(
            user_1_friend_ref,
            {
                "friend_id": user_id_2,
                "friendship_id": friendship["id"],
                "created_at": friendship["created_at"],
            },
            merge=True,
        )
        batch.set(
            user_2_friend_ref,
            {
                "friend_id": user_id_1,
                "friendship_id": friendship["id"],
                "created_at": friendship["created_at"],
            },
            merge=True,
        )
        batch.commit()
        return friendship


class FriendService:
    def __init__(self, repository=None):
        self.repository = repository or FirestoreFriendRepository()

    def list_friends(self, user_id: str, page: int = 1, limit: int = 20) -> dict:
        page, limit = self._normalize_pagination(page, limit)
        refs = self.repository.list_friend_refs(user_id, page, limit)
        friends = []
        for ref in refs:
            friend_id = ref.get("friend_id") or ref.get("id")
            if not friend_id:
                continue
            profile = self.repository.get_user(friend_id)
            summary = _profile_summary(profile, friend_id)
            summary["friendship_id"] = ref.get("friendship_id")
            summary["created_at"] = ref.get("created_at")
            friends.append(summary)

        return {
            "friends": friends,
            "page": page,
            "limit": limit,
            "has_next": len(refs) == limit,
        }

    def search_users(self, user_id: str, query: str, limit: int = 20) -> dict:
        query = _normalize_text(query)
        limit = max(1, min(int(limit), 50))
        users = self.repository.search_users(query, limit)
        results = []
        for user in users:
            candidate_id = user.get("uid") or user.get("id")
            if not candidate_id or candidate_id == user_id:
                continue

            haystack = " ".join(
                _normalize_text(value)
                for value in [
                    user.get("display_name"),
                    user.get("firstName"),
                    user.get("lastName"),
                    user.get("email"),
                    candidate_id,
                ]
            )
            if query and query not in haystack:
                continue

            results.append(
                {
                    "user": _profile_summary(user, candidate_id),
                    "relationship_status": self.get_relationship_status(
                        user_id,
                        candidate_id,
                    ),
                }
            )
            if len(results) >= limit:
                break

        return {"results": results, "query": query}

    def list_received_requests(self, user_id: str) -> dict:
        requests = []
        for request in self.repository.list_received_requests(user_id):
            sender_id = request.get("sender_id")
            request["sender"] = _profile_summary(
                self.repository.get_user(sender_id),
                sender_id,
            )
            requests.append(request)
        return {"requests": requests}

    def send_request(self, sender_id: str, receiver_id: str) -> dict:
        if not receiver_id:
            raise FriendServiceValidationError("receiver_id is required")
        if sender_id == receiver_id:
            raise FriendServiceValidationError("Cannot send a friend request to yourself")
        if not self.repository.get_user(receiver_id):
            raise FriendServiceNotFoundError("Receiver not found")
        if self.are_friends(sender_id, receiver_id):
            raise FriendServiceValidationError("Users are already friends")
        if self.repository.find_pending_request(sender_id, receiver_id):
            raise FriendServiceValidationError("Friend request already sent")
        if self.repository.find_pending_request(receiver_id, sender_id):
            raise FriendServiceValidationError("This user already sent you a request")

        now = _now_iso()
        request = {
            "id": f"request_{uuid.uuid4().hex}",
            "sender_id": sender_id,
            "receiver_id": receiver_id,
            "status": "pending",
            "created_at": now,
            "updated_at": now,
        }
        return self.repository.create_request(request)

    def accept_request(self, user_id: str, request_id: str) -> dict:
        request = self._get_pending_request_for_receiver(user_id, request_id)
        friendship_id = _stable_friendship_id(
            request["sender_id"],
            request["receiver_id"],
        )
        existing = self.repository.get_friendship(friendship_id)
        if existing:
            updated_request = self.repository.update_request(
                request_id,
                {
                    "status": "accepted",
                    "updated_at": _now_iso(),
                    "friendship_id": friendship_id,
                },
            )
            return {"request": updated_request, "friendship": existing}

        friendship = {
            "id": friendship_id,
            "user_ids": sorted([request["sender_id"], request["receiver_id"]]),
            "created_at": _now_iso(),
        }
        created_friendship = self.repository.create_friendship(friendship, request_id)
        accepted_request = self.repository.get_request(request_id) or {
            **request,
            "status": "accepted",
            "friendship_id": friendship_id,
        }
        return {"request": accepted_request, "friendship": created_friendship}

    def decline_request(self, user_id: str, request_id: str) -> dict:
        self._get_pending_request_for_receiver(user_id, request_id)
        return self.repository.update_request(
            request_id,
            {
                "status": "declined",
                "updated_at": _now_iso(),
            },
        )

    def get_relationship_status(self, user_id: str, other_user_id: str) -> str:
        if self.are_friends(user_id, other_user_id):
            return "friend"
        if self.repository.find_pending_request(user_id, other_user_id):
            return "request_sent"
        if self.repository.find_pending_request(other_user_id, user_id):
            return "request_received"
        return "available"

    def are_friends(self, user_id: str, other_user_id: str) -> bool:
        return self.repository.get_friendship(
            _stable_friendship_id(user_id, other_user_id)
        ) is not None

    def _get_pending_request_for_receiver(self, user_id: str, request_id: str) -> dict:
        request = self.repository.get_request(request_id)
        if not request:
            raise FriendServiceNotFoundError("Friend request not found")
        if request.get("receiver_id") != user_id:
            raise FriendServicePermissionError("You cannot manage this friend request")
        if request.get("status") != "pending":
            raise FriendServiceValidationError("Friend request is not pending")
        return request

    def _normalize_pagination(self, page: int, limit: int) -> tuple[int, int]:
        page = max(1, int(page))
        limit = max(1, min(int(limit), 50))
        return page, limit
