from django.test import TestCase
from .models import Message


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
