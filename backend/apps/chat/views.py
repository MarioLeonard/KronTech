from rest_framework.views import APIView
from rest_framework import status
from rest_framework.pagination import PageNumberPagination
from django.db.models import Q
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from .models import Message
from .serializers import MessageSerializer
from common.api.responses import success_response, error_response
from common.services.chat_service import ChatService


def _get_request_user_id(request):
    auth_user = getattr(request, "auth_user", None)
    if isinstance(auth_user, dict):
        return auth_user.get("uid")
    return getattr(request, "auth_user_id", None)


class MessagePagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'limit'
    max_page_size = 100


class ConversationListView(APIView):
    """Get list of conversations for the logged-in user"""

    def get(self, request):
        user_id = _get_request_user_id(request)
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        conv_data = ChatService.get_user_conversations(user_id)

        return success_response(
            data={'conversations': conv_data},
            message="Conversations retrieved successfully"
        )


class MessageListView(APIView):
    """Get paginated messages from a conversation"""

    def get(self, request, conversation_id):
        user_id = _get_request_user_id(request)
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        # Verify user is part of this conversation
        messages = Message.objects.filter(
            conversation_id=conversation_id,
        ).order_by("timestamp")
        
        if not messages.exists():
            if not ChatService.user_has_conversation_access(conversation_id, user_id):
                return error_response("Conversation not found", status.HTTP_404_NOT_FOUND)

            return success_response(
                data={
                    'messages': [],
                    'count': 0,
                    'total_pages': 0,
                    'current_page': 1,
                    'has_next': False,
                },
                message="Messages retrieved successfully",
            )

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
        user_id = _get_request_user_id(request)
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        content = request.data.get('content', '').strip()
        
        if not content:
            return error_response("Message content cannot be empty", status.HTTP_400_BAD_REQUEST)

        if len(content) > 5000:
            return error_response("Message is too long (max 5000 characters)", status.HTTP_400_BAD_REQUEST)

        try:
            message = ChatService.create_message(user_id, receiver_id, content)
        except ValueError as error:
            return error_response(str(error), status.HTTP_400_BAD_REQUEST)

        serializer = MessageSerializer(message)
        sender_name = (
            ChatService.get_user_summary(message.sender_id).get("name")
            or message.sender_id
        )
        channel_layer = get_channel_layer()
        if channel_layer is not None:
            async_to_sync(channel_layer.group_send)(
                f"user_notifications_{receiver_id}",
                {
                    "type": "chat_notification_event",
                    "message_id": str(message.id),
                    "id": str(message.id),
                    "conversation_id": message.conversation_id,
                    "sender_id": message.sender_id,
                    "sender_name": sender_name,
                    "receiver_id": message.receiver_id,
                    "content": message.content,
                    "timestamp": message.timestamp.isoformat(),
                    "is_read": message.is_read,
                },
            )
        return success_response(
            data=serializer.data,
            message="Message sent successfully",
            status_code=status.HTTP_201_CREATED
        )


class MarkMessagesAsReadView(APIView):
    """Mark all messages in a conversation as read"""

    def post(self, request, conversation_id):
        user_id = _get_request_user_id(request)
        
        if not user_id:
            return error_response("User not authenticated", status.HTTP_401_UNAUTHORIZED)

        if not ChatService.user_has_conversation_access(conversation_id, user_id):
            return error_response("Access denied", status.HTTP_403_FORBIDDEN)

        updated_count = ChatService.mark_messages_as_read(
            conversation_id,
            user_id,
        )

        return success_response(
            data={'updated_count': updated_count},
            message="Messages marked as read"
        )
