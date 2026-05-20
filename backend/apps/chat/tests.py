from datetime import datetime, timezone

from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIRequestFactory
from unittest.mock import Mock, patch

from .models import Message
from .views import MessageListView
from common.services.chat_service import ChatService


class MessageModelTest(TestCase):
    """Test cases for Message model"""

    def setUp(self):
        self.message = Message.objects.create(
            sender_id="user123",
            receiver_id="user456",
            content="Hello World",
            conversation_id="conv_user123_user456"
        )

    def test_message_creation(self):
        """Test that a message can be created"""
        self.assertEqual(self.message.sender_id, "user123")
        self.assertEqual(self.message.receiver_id, "user456")
        self.assertFalse(self.message.is_read)

    def test_message_string_representation(self):
        """Test message string representation"""
        expected = "Message from user123 to user456"
        self.assertEqual(str(self.message), expected)


class ChatConversationServiceTest(TestCase):
    @patch("common.services.chat_service.ChatService.get_user_summary")
    @patch("common.services.chat_service.ChatService._get_firestore_conversations")
    def test_list_conversations_include_friend_without_messages(
        self,
        mock_conversations,
        mock_user_summary,
    ):
        conversation_id = ChatService.generate_conversation_id("alice", "bob")
        mock_conversations.return_value = [
            {
                "conversation_id": conversation_id,
                "participants": ["alice", "bob"],
                "created_at": "2026-05-10T10:00:00+00:00",
                "updated_at": "2026-05-10T10:00:00+00:00",
                "last_message": "",
                "last_message_id": None,
                "last_message_sender_id": None,
                "last_message_timestamp": None,
                "unread_counts": {"alice": 0, "bob": 0},
            }
        ]
        mock_user_summary.return_value = {
            "id": "bob",
            "name": "Bob",
            "avatar_url": None,
        }

        conversations = ChatService.get_user_conversations("alice")

        self.assertEqual(len(conversations), 1)
        self.assertEqual(conversations[0]["conversation_id"], conversation_id)
        self.assertEqual(conversations[0]["other_user_id"], "bob")
        self.assertEqual(conversations[0]["last_message"], "")
        self.assertEqual(conversations[0]["unread_count"], 0)

    @patch("common.services.chat_service.ChatService.get_user_summary")
    @patch("common.services.chat_service.ChatService._get_firestore_conversations")
    def test_list_conversations_sorts_mixed_timestamp_types(
        self,
        mock_conversations,
        mock_user_summary,
    ):
        older_conversation_id = ChatService.generate_conversation_id("alice", "bob")
        newer_conversation_id = ChatService.generate_conversation_id("alice", "cara")
        mock_conversations.return_value = [
            {
                "conversation_id": older_conversation_id,
                "participants": ["alice", "bob"],
                "created_at": "2026-05-10T10:00:00+00:00",
                "updated_at": "2026-05-10T10:00:00+00:00",
                "last_message": "",
                "last_message_timestamp": None,
                "unread_counts": {"alice": 0, "bob": 0},
            },
            {
                "conversation_id": newer_conversation_id,
                "participants": ["alice", "cara"],
                "last_message": "Hello",
                "last_message_timestamp": datetime(
                    2026,
                    5,
                    10,
                    11,
                    0,
                    tzinfo=timezone.utc,
                ),
                "unread_counts": {"alice": 1, "cara": 0},
            },
        ]
        mock_user_summary.side_effect = lambda user_id: {
            "id": user_id,
            "name": user_id,
            "avatar_url": None,
        }

        conversations = ChatService.get_user_conversations("alice")

        self.assertEqual(conversations[0]["conversation_id"], newer_conversation_id)
        self.assertEqual(conversations[1]["conversation_id"], older_conversation_id)
        self.assertIsInstance(conversations[0]["last_message_timestamp"], str)

    @patch("common.services.chat_service.ChatService.get_conversation")
    def test_messages_endpoint_returns_empty_for_empty_conversation(
        self,
        mock_get_conversation,
    ):
        conversation_id = ChatService.generate_conversation_id("alice", "bob")
        mock_get_conversation.return_value = {
            "conversation_id": conversation_id,
            "participants": ["alice", "bob"],
        }
        request = APIRequestFactory().get(
            f"/api/chat/conversations/{conversation_id}/messages/",
        )
        request.auth_user = {"uid": "alice"}

        response = MessageListView.as_view()(request, conversation_id=conversation_id)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"]["messages"], [])
        self.assertEqual(response.data["data"]["count"], 0)

    @patch("common.services.chat_service.FirestoreService")
    def test_backfill_creates_missing_friend_conversations(self, mock_firestore):
        db = _FakeFirestoreDb(
            friendships=[
                {
                    "id": "friendship_1",
                    "user_ids": ["alice", "bob"],
                    "created_at": "2026-05-10T10:00:00+00:00",
                }
            ],
            existing_conversations=set(),
        )
        mock_firestore.return_value._db = db

        result = ChatService.backfill_friend_conversations()

        self.assertEqual(result["created"], 1)
        self.assertEqual(result["skipped"], 0)
        self.assertEqual(len(db.conversations), 1)

    @patch("common.services.chat_service.FirestoreService")
    def test_backfill_does_not_duplicate_existing_conversations(self, mock_firestore):
        conversation_id = ChatService.generate_conversation_id("alice", "bob")
        db = _FakeFirestoreDb(
            friendships=[
                {
                    "id": "friendship_1",
                    "user_ids": ["alice", "bob"],
                    "created_at": "2026-05-10T10:00:00+00:00",
                }
            ],
            existing_conversations={conversation_id},
        )
        mock_firestore.return_value._db = db

        result = ChatService.backfill_friend_conversations()

        self.assertEqual(result["created"], 0)
        self.assertEqual(result["skipped"], 1)
        self.assertEqual(db.write_count, 0)


class _FakeDocSnapshot:
    def __init__(self, doc_id, data=None, exists=True):
        self.id = doc_id
        self._data = data or {}
        self.exists = exists

    def to_dict(self):
        return self._data.copy()


class _FakeDocRef:
    def __init__(self, collection, doc_id):
        self.collection = collection
        self.id = doc_id

    def get(self):
        if self.collection.name == "conversations":
            data = self.collection.db.conversations.get(self.id)
            return _FakeDocSnapshot(self.id, data, data is not None)
        return _FakeDocSnapshot(self.id, exists=False)

    def set(self, data, merge=False):
        self.collection.db.write_count += 1
        self.collection.db.conversations[self.id] = data.copy()


class _FakeCollection:
    def __init__(self, db, name):
        self.db = db
        self.name = name

    def document(self, doc_id):
        return _FakeDocRef(self, doc_id)

    def stream(self):
        if self.name != "friendships":
            return iter([])
        return iter(
            _FakeDocSnapshot(item["id"], item)
            for item in self.db.friendships
        )


class _FakeFirestoreDb:
    def __init__(self, friendships, existing_conversations):
        self.friendships = friendships
        self.conversations = {
            conversation_id: {"conversation_id": conversation_id}
            for conversation_id in existing_conversations
        }
        self.write_count = 0

    def collection(self, name):
        return _FakeCollection(self, name)
