from django.test import TestCase
from rest_framework.test import APIRequestFactory

from apps.friends.views import FriendListView
from common.services.friend_service import (
    FriendService,
    FriendServicePermissionError,
    FriendServiceValidationError,
)


class FakeFriendRepository:
    def __init__(self):
        self.users = {
            "alice": {
                "id": "alice",
                "uid": "alice",
                "display_name": "Alice Pop",
                "email": "alice@example.com",
            },
            "bob": {
                "id": "bob",
                "uid": "bob",
                "display_name": "Bob Ionescu",
                "email": "bob@example.com",
            },
            "cara": {
                "id": "cara",
                "uid": "cara",
                "display_name": "Cara Test",
                "email": "cara@example.com",
            },
        }
        self.requests = {}
        self.friendships = {}
        self.friend_refs = {"alice": {}, "bob": {}, "cara": {}}

    def get_user(self, user_id):
        return self.users.get(user_id)

    def search_users(self, query, limit):
        return list(self.users.values())[:limit]

    def list_friend_refs(self, user_id, page, limit):
        refs = list(self.friend_refs.get(user_id, {}).values())
        start = (page - 1) * limit
        return refs[start:start + limit]

    def find_pending_request(self, sender_id, receiver_id):
        for request in self.requests.values():
            if (
                request["sender_id"] == sender_id
                and request["receiver_id"] == receiver_id
                and request["status"] == "pending"
            ):
                return request.copy()
        return None

    def get_request(self, request_id):
        request = self.requests.get(request_id)
        return request.copy() if request else None

    def list_received_requests(self, user_id):
        return [
            request.copy()
            for request in self.requests.values()
            if request["receiver_id"] == user_id and request["status"] == "pending"
        ]

    def create_request(self, data):
        self.requests[data["id"]] = data.copy()
        return data.copy()

    def update_request(self, request_id, data):
        self.requests[request_id].update(data)
        return self.requests[request_id].copy()

    def get_friendship(self, friendship_id):
        friendship = self.friendships.get(friendship_id)
        return friendship.copy() if friendship else None

    def create_friendship(self, friendship, request_id):
        self.friendships[friendship["id"]] = friendship.copy()
        sender_id, receiver_id = friendship["user_ids"]
        self.requests[request_id].update(
            {
                "status": "accepted",
                "updated_at": friendship["created_at"],
                "friendship_id": friendship["id"],
            }
        )
        self.friend_refs[sender_id][receiver_id] = {
            "id": receiver_id,
            "friend_id": receiver_id,
            "friendship_id": friendship["id"],
            "created_at": friendship["created_at"],
        }
        self.friend_refs[receiver_id][sender_id] = {
            "id": sender_id,
            "friend_id": sender_id,
            "friendship_id": friendship["id"],
            "created_at": friendship["created_at"],
        }
        return friendship.copy()


class FriendServiceTest(TestCase):
    def setUp(self):
        self.repo = FakeFriendRepository()
        self.service = FriendService(repository=self.repo)

    def test_list_friends(self):
        request = self.service.send_request("alice", "bob")
        self.service.accept_request("bob", request["id"])

        data = self.service.list_friends("alice", page=1, limit=10)

        self.assertEqual(len(data["friends"]), 1)
        self.assertEqual(data["friends"][0]["id"], "bob")
        self.assertEqual(data["friends"][0]["name"], "Bob Ionescu")
        self.assertFalse(data["has_next"])

    def test_search_users_includes_relationship_status(self):
        request = self.service.send_request("alice", "bob")

        data = self.service.search_users("alice", query="bob", limit=10)

        self.assertEqual(len(data["results"]), 1)
        self.assertEqual(data["results"][0]["user"]["id"], "bob")
        self.assertEqual(data["results"][0]["relationship_status"], "request_sent")
        self.assertEqual(self.service.search_users("bob", "alice")["results"][0]["relationship_status"], "request_received")
        self.service.accept_request("bob", request["id"])
        self.assertEqual(self.service.search_users("alice", "bob")["results"][0]["relationship_status"], "friend")

    def test_send_request(self):
        request = self.service.send_request("alice", "bob")

        self.assertEqual(request["sender_id"], "alice")
        self.assertEqual(request["receiver_id"], "bob")
        self.assertEqual(request["status"], "pending")

    def test_duplicate_request_is_rejected(self):
        self.service.send_request("alice", "bob")

        with self.assertRaises(FriendServiceValidationError):
            self.service.send_request("alice", "bob")

    def test_accept_request(self):
        request = self.service.send_request("alice", "bob")

        data = self.service.accept_request("bob", request["id"])

        self.assertEqual(data["request"]["status"], "accepted")
        self.assertIn("alice", data["friendship"]["user_ids"])
        self.assertIn("bob", data["friendship"]["user_ids"])
        self.assertTrue(self.service.are_friends("alice", "bob"))

    def test_decline_request(self):
        request = self.service.send_request("alice", "bob")

        declined = self.service.decline_request("bob", request["id"])

        self.assertEqual(declined["status"], "declined")
        self.assertFalse(self.service.are_friends("alice", "bob"))

    def test_unauthorized_access_to_request_is_rejected(self):
        request = self.service.send_request("alice", "bob")

        with self.assertRaises(FriendServicePermissionError):
            self.service.accept_request("cara", request["id"])


class FriendViewsAuthTest(TestCase):
    def test_friend_list_requires_authentication(self):
        request = APIRequestFactory().get("/api/friends/")

        response = FriendListView.as_view()(request)

        self.assertEqual(response.status_code, 401)
