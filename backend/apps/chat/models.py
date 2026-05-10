from django.db import models


class Message(models.Model):
    """
    Message model for storing chat messages between two users.
    Uses Firebase UIDs for user identification instead of Django User model.
    """
    sender_id = models.CharField(
        max_length=255,
        help_text="Firebase UID of the message sender"
    )
    receiver_id = models.CharField(
        max_length=255,
        help_text="Firebase UID of the message receiver"
    )
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)
    conversation_id = models.CharField(
        max_length=255,
        db_index=True,
        help_text="Unique identifier for a conversation between two users"
    )

    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['conversation_id', '-timestamp']),
            models.Index(fields=['receiver_id', 'is_read']),
        ]

    def __str__(self):
        return f"Message from {self.sender_id} to {self.receiver_id}"
