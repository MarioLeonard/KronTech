import hashlib
from django.db.models import Q
from apps.chat.models import Message
from common.firebase.database import db


class ChatService:
    """Service for handling chat-related business logic"""

    @staticmethod
    def generate_conversation_id(user_id_1: str, user_id_2: str) -> str:
        """Generate a unique conversation ID from two user IDs"""
        user_ids = sorted([user_id_1, user_id_2])
        return f"conv_{'_'.join(user_ids)}"

    @staticmethod
    def create_message(sender_id: str, receiver_id: str, content: str) -> Message:
        """Create a new message and save to both DB and Firestore"""
        conversation_id = ChatService.generate_conversation_id(sender_id, receiver_id)
        
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
        """Save message to Firestore collection"""
        try:
            # Create collection path: conversations/{conv_id}/messages
            doc_ref = db.collection('conversations').document(conversation_id).collection('messages').document(str(message.id))
            doc_ref.set({
                'sender_id': message.sender_id,
                'receiver_id': message.receiver_id,
                'content': message.content,
                'timestamp': message.timestamp,
                'is_read': message.is_read,
                'message_id': message.id
            })
        except Exception as e:
            # Log error but don't fail the request
            print(f"Error saving message to Firestore: {str(e)}")

    @staticmethod
    def get_conversation_messages(conversation_id: str, page: int = 1, limit: int = 10) -> dict:
        """Get paginated messages from a conversation"""
        messages = Message.objects.filter(conversation_id=conversation_id)
        
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
        # Get all messages where user is sender or receiver
        messages = Message.objects.filter(
            Q(sender_id=user_id) | Q(receiver_id=user_id)
        ).distinct('conversation_id').order_by('conversation_id', '-timestamp')

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
                    'last_message': msg.content,
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
        return updated

    @staticmethod
    def get_unread_count(user_id: str) -> int:
        """Get total unread messages for a user"""
        return Message.objects.filter(
            receiver_id=user_id,
            is_read=False
        ).count()
