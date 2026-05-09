from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.pagination import PageNumberPagination
from django.db.models import Q
from .models import Message
from .serializers import MessageSerializer
from common.api.responses import success_response, error_response


class MessagePagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'limit'
    max_page_size = 100


class ConversationListView(APIView):
    """Get list of conversations for the logged-in user"""

    def get(self, request):
        user_id = request.user.get('uid')  # Firebase UID from token
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        # Get unique conversations where user is either sender or receiver
        # Get last message from each conversation
        conversations = Message.objects.filter(
            Q(sender_id=user_id) | Q(receiver_id=user_id)
        ).distinct('conversation_id').order_by('conversation_id', '-timestamp')

        # Build conversation list with last message preview
        conv_data = []
        processed_convs = set()

        for msg in conversations:
            if msg.conversation_id not in processed_convs:
                other_user = msg.receiver_id if msg.sender_id == user_id else msg.sender_id
                conv_data.append({
                    'conversation_id': msg.conversation_id,
                    'other_user_id': other_user,
                    'last_message': msg.content,
                    'last_message_timestamp': msg.timestamp,
                    'unread_count': Message.objects.filter(
                        conversation_id=msg.conversation_id,
                        receiver_id=user_id,
                        is_read=False
                    ).count()
                })
                processed_convs.add(msg.conversation_id)

        return success_response(
            data={'conversations': conv_data},
            message="Conversations retrieved successfully"
        )


class MessageListView(APIView):
    """Get paginated messages from a conversation"""

    def get(self, request, conversation_id):
        user_id = request.user.get('uid')
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        # Verify user is part of this conversation
        messages = Message.objects.filter(conversation_id=conversation_id)
        
        if not messages.exists():
            return error_response("Conversation not found", status.HTTP_404_NOT_FOUND)

        # Check if user is part of conversation
        if not messages.filter(Q(sender_id=user_id) | Q(receiver_id=user_id)).exists():
            return error_response("Access denied", status.HTTP_403_FORBIDDEN)

        # Pagination
        paginator = MessagePagination()
        paginated_messages = paginator.paginate_queryset(messages, request)
        serializer = MessageSerializer(paginated_messages, many=True)

        return success_response(
            data={
                'messages': serializer.data,
                'count': paginator.page.paginator.count,
                'total_pages': paginator.page.paginator.num_pages,
                'current_page': paginator.page.number,
                'has_next': paginator.page.has_next(),
            },
            message="Messages retrieved successfully"
        )


class SendMessageView(APIView):
    """Send a message to another user"""

    def post(self, request, receiver_id):
        user_id = request.user.get('uid')
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        content = request.data.get('content', '').strip()
        
        if not content:
            return error_response("Message content cannot be empty", status.HTTP_400_BAD_REQUEST)

        if len(content) > 5000:
            return error_response("Message is too long (max 5000 characters)", status.HTTP_400_BAD_REQUEST)

        # Generate conversation ID (sorted user IDs for consistency)
        user_ids = sorted([user_id, receiver_id])
        conversation_id = f"conv_{'_'.join(user_ids)}"

        # Create message
        message = Message.objects.create(
            sender_id=user_id,
            receiver_id=receiver_id,
            content=content,
            conversation_id=conversation_id
        )

        # TODO: Save to Firestore for real-time sync
        # TODO: Broadcast via WebSocket to receiver

        serializer = MessageSerializer(message)
        return success_response(
            data=serializer.data,
            message="Message sent successfully",
            status_code=status.HTTP_201_CREATED
        )


class MarkMessagesAsReadView(APIView):
    """Mark all messages in a conversation as read"""

    def post(self, request, conversation_id):
        user_id = request.user.get('uid')
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        # Update messages where user is receiver
        updated_count = Message.objects.filter(
            conversation_id=conversation_id,
            receiver_id=user_id,
            is_read=False
        ).update(is_read=True)

        return success_response(
            data={'updated_count': updated_count},
            message="Messages marked as read"
        )
