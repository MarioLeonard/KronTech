import hashlib
import logging
from typing import Iterable, Optional

from django.db.models import Q
from django.utils import timezone
from firebase_admin import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

from apps.core.models import UserProfile
from apps.chat.models import Message
from common.firebase.database import FirestoreService

logger = logging.getLogger(__name__)


class ChatService:
    """Service for handling chat-related business logic"""

    @staticmethod
    def generate_conversation_id(user_id_1: str, user_id_2: str) -> str:
        """Generate a unique conversation ID from two user IDs"""
        user_ids = sorted([user_id_1, user_id_2])
        digest = hashlib.sha256("|".join(user_ids).encode("utf-8")).hexdigest()
        return f"conv_{digest[:32]}"

    @staticmethod
    def create_message(
        sender_id: str,
        receiver_id: str,
        content: str,
        conversation_id: Optional[str] = None,
    ) -> Message:
        """Create a new message and save to both DB and Firestore"""
        expected_conversation_id = ChatService.generate_conversation_id(
            sender_id,
            receiver_id,
        )
        conversation_id = conversation_id or expected_conversation_id

        if conversation_id != expected_conversation_id:
            existing = Message.objects.filter(
                conversation_id=conversation_id,
            ).filter(
                Q(sender_id=sender_id, receiver_id=receiver_id)
                | Q(sender_id=receiver_id, receiver_id=sender_id)
            )
            if not existing.exists():
                raise ValueError("Conversation does not match participants")
        
        # Save to Django DB
        message = Message.objects.create(
            sender_id=sender_id,
            receiver_id=receiver_id,
            content=content,
            conversation_id=conversation_id
        )
        
        # Save to Firestore for real-time sync
        ChatService._save_to_firestore(message, conversation_id)
        
        return message

    @staticmethod
    def _save_to_firestore(message: Message, conversation_id: str):
        """Save message and conversation metadata to Firestore."""
        try:
            service = FirestoreService()
            db = service._db
            conversation_ref = db.collection("conversations").document(
                conversation_id,
            )
            message_ref = conversation_ref.collection("messages").document(
                str(message.id),
            )
            participants = sorted([message.sender_id, message.receiver_id])
            timestamp = message.timestamp or timezone.now()
            message_payload = {
                "message_id": str(message.id),
                "sender_id": message.sender_id,
                "receiver_id": message.receiver_id,
                "content": message.content,
                "timestamp": timestamp,
                "is_read": message.is_read,
                "conversation_id": conversation_id,
            }
            conversation_payload = {
                "conversation_id": conversation_id,
                "participants": participants,
                "last_message": message.content,
                "last_message_id": str(message.id),
                "last_message_sender_id": message.sender_id,
                "last_message_timestamp": timestamp,
                "updated_at": firestore.SERVER_TIMESTAMP,
                "unread_counts": {
                    message.receiver_id: firestore.Increment(1),
                    message.sender_id: firestore.Increment(0),
                },
            }

            batch = db.batch()
            batch.set(message_ref, message_payload, merge=True)
            batch.set(conversation_ref, conversation_payload, merge=True)
            batch.commit()
        except Exception as e:
            # Log error but don't fail the request
            logger.exception("Error saving chat message to Firestore: %s", e)

    @staticmethod
    def get_conversation_messages(conversation_id: str, page: int = 1, limit: int = 10) -> dict:
        """Get paginated messages from a conversation"""
        messages = Message.objects.filter(
            conversation_id=conversation_id,
        ).order_by("timestamp")
        
        total_count = messages.count()
        start_idx = (page - 1) * limit
        end_idx = start_idx + limit
        
        paginated_messages = messages[start_idx:end_idx]
        
        return {
            'messages': paginated_messages,
            'total': total_count,
            'page': page,
            'limit': limit,
            'total_pages': (total_count + limit - 1) // limit,
            'has_next': end_idx < total_count
        }

    @staticmethod
    def get_user_conversations(user_id: str) -> list:
        """Get all conversations for a user"""
        messages = Message.objects.filter(
            Q(sender_id=user_id) | Q(receiver_id=user_id)
        ).order_by("-timestamp")

        conversations = []
        processed_convs = set()

        for msg in messages:
            if msg.conversation_id not in processed_convs:
                other_user = msg.receiver_id if msg.sender_id == user_id else msg.sender_id
                
                unread_count = Message.objects.filter(
                    conversation_id=msg.conversation_id,
                    receiver_id=user_id,
                    is_read=False
                ).count()
                
                conversations.append({
                    'conversation_id': msg.conversation_id,
                    'other_user_id': other_user,
                    'other_user': ChatService.get_user_summary(other_user),
                    'last_message': msg.content,
                    'last_message_sender_id': msg.sender_id,
                    'last_message_timestamp': msg.timestamp,
                    'unread_count': unread_count
                })
                processed_convs.add(msg.conversation_id)

        return conversations

    @staticmethod
    def mark_messages_as_read(conversation_id: str, user_id: str) -> int:
        """Mark all unread messages in a conversation as read"""
        updated = Message.objects.filter(
            conversation_id=conversation_id,
            receiver_id=user_id,
            is_read=False
        ).update(is_read=True)
        ChatService._mark_firestore_messages_as_read(conversation_id, user_id)
        return updated

    @staticmethod
    def user_has_conversation_access(conversation_id: str, user_id: str) -> bool:
        """Return whether a Firebase UID participates in a conversation."""
        return Message.objects.filter(conversation_id=conversation_id).filter(
            Q(sender_id=user_id) | Q(receiver_id=user_id)
        ).exists()

    @staticmethod
    def get_conversation_participants(conversation_id: str) -> Iterable[str]:
        """Return participant IDs known from local messages."""
        message = Message.objects.filter(conversation_id=conversation_id).first()
        if not message:
            return []
        return sorted([message.sender_id, message.receiver_id])

    @staticmethod
    def get_user_summary(user_id: str) -> dict:
        """Read lightweight participant profile data from Firestore if available."""
        try:
            profile = UserProfile.get_by_uid(user_id)
            if profile:
                data = profile.to_dict()
                display_name = (
                    data.get("display_name")
                    or " ".join(
                        part
                        for part in [data.get("firstName"), data.get("lastName")]
                        if part
                    ).strip()
                    or data.get("email")
                )
                return {
                    "id": user_id,
                    "name": display_name or user_id,
                    "avatar_url": data.get("profilePhotoUrl") or data.get("photo_url"),
                }
        except Exception:
            logger.debug("Could not load chat profile for %s", user_id, exc_info=True)

        return {
            "id": user_id,
            "name": user_id,
            "avatar_url": None,
        }

    @staticmethod
    def _mark_firestore_messages_as_read(conversation_id: str, user_id: str) -> None:
        """Best-effort Firestore read-state sync."""
        try:
            db = FirestoreService()._db
            conversation_ref = db.collection("conversations").document(
                conversation_id,
            )
            unread_messages = (
                conversation_ref.collection("messages")
                .where(filter=FieldFilter("receiver_id", "==", user_id))
                .where(filter=FieldFilter("is_read", "==", False))
                .stream()
            )
            batch = db.batch()
            for doc in unread_messages:
                batch.update(doc.reference, {"is_read": True})
            batch.set(
                conversation_ref,
                {"unread_counts": {user_id: 0}},
                merge=True,
            )
            batch.commit()
        except Exception:
            logger.debug(
                "Could not mark Firestore chat messages as read",
                exc_info=True,
            )

    @staticmethod
    def get_unread_count(user_id: str) -> int:
        """Get total unread messages for a user"""
        return Message.objects.filter(
            receiver_id=user_id,
            is_read=False
        ).count()
