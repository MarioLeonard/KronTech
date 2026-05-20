import json
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncWebsocketConsumer
from common.services.chat_service import ChatService
from common.services.presence_service import PresenceService


class ChatConsumer(AsyncWebsocketConsumer):
    """WebSocket consumer for real-time chat messaging"""

    async def connect(self):
        """Handle WebSocket connection"""
        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.user_id = self.scope['user'].get('uid') if self.scope.get('user') else None
        
        # Validate user authentication
        if not self.user_id:
            await self.close(code=4001)  # Unauthorized
            return

        if not await self.user_has_access(self.conversation_id, self.user_id):
            await self.close(code=4003)
            return

        # Create room group name
        self.room_group_name = f'chat_{self.conversation_id}'

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        presence = await self.mark_user_online(self.user_id)
        await self.accept()
        
        # Notify others that user connected
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'user_connected',
                'user_id': self.user_id,
                **presence,
            }
        )

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection"""
        if hasattr(self, 'room_group_name'):
            presence = await self.mark_user_offline(self.user_id)
            # Notify others that user disconnected
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'user_disconnected',
                    'user_id': self.user_id,
                    **presence,
                }
            )
            
            # Leave room group
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        """Handle incoming WebSocket message"""
        try:
            data = json.loads(text_data)
            message_type = data.get('type')
            
            if message_type == 'chat_message':
                await self.handle_chat_message(data)
            elif message_type == 'typing':
                await self.handle_typing(data)
            elif message_type == 'mark_read':
                await self.handle_mark_read(data)
        except json.JSONDecodeError:
            await self.send_error("Invalid JSON")

    async def handle_chat_message(self, data):
        """Handle incoming chat message"""
        content = data.get('content', '').strip()
        receiver_id = data.get('receiver_id') or await self.get_other_participant()
        
        if not content:
            await self.send_error("Message content cannot be empty")
            return

        if not receiver_id:
            await self.send_error("Message receiver is required")
            return
        
        if len(content) > 5000:
            await self.send_error("Message too long")
            return

        # Save message to database
        message = await self.save_message(
            self.user_id,
            receiver_id,
            content,
            self.conversation_id,
        )
        
        if message:
            # Broadcast message to group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message_event',
                    **message,
                }
            )
            await self.channel_layer.group_send(
                f"user_notifications_{receiver_id}",
                {
                    "type": "chat_notification_event",
                    **message,
                },
            )
        else:
            await self.send_error("Could not save message")

    async def handle_typing(self, data):
        """Handle typing indicator"""
        is_typing = data.get('is_typing', False)
        
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'typing_indicator',
                'user_id': self.user_id,
                'is_typing': is_typing
            }
        )

    async def handle_mark_read(self, data):
        """Handle mark as read"""
        await self.mark_messages_as_read(self.conversation_id, self.user_id)
        
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'messages_marked_read',
                'user_id': self.user_id,
                'conversation_id': self.conversation_id
            }
        )

    # Event handlers (called by group_send)
    async def chat_message_event(self, event):
        """Send chat message to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'chat_message',
            'message_id': event['message_id'],
            'sender_id': event['sender_id'],
            'receiver_id': event['receiver_id'],
            'content': event['content'],
            'timestamp': event['timestamp'],
            'is_read': event['is_read']
        }))

    async def typing_indicator(self, event):
        """Send typing indicator to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'typing',
            'user_id': event['user_id'],
            'is_typing': event['is_typing']
        }))

    async def messages_marked_read(self, event):
        """Send mark as read event to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'messages_marked_read',
            'user_id': event['user_id'],
            'conversation_id': event['conversation_id']
        }))

    async def user_connected(self, event):
        """Send user connected event to WebSocket"""
        if event['user_id'] != self.user_id:  # Don't send to self
            await self.send(text_data=json.dumps({
                'type': 'user_connected',
                'user_id': event['user_id'],
                'status': event.get('status'),
                'last_seen': event.get('last_seen'),
            }))

    async def user_disconnected(self, event):
        """Send user disconnected event to WebSocket"""
        if event['user_id'] != self.user_id:  # Don't send to self
            await self.send(text_data=json.dumps({
                'type': 'user_disconnected',
                'user_id': event['user_id'],
                'status': event.get('status'),
                'last_seen': event.get('last_seen'),
            }))

    # Database operations (sync to async)
    @database_sync_to_async
    def save_message(
        self,
        sender_id: str,
        receiver_id: str,
        content: str,
        conversation_id: str,
    ):
        """Save message to database asynchronously"""
        try:
            message = ChatService.create_message(
                sender_id,
                receiver_id,
                content,
                conversation_id=conversation_id,
            )
            sender_summary = ChatService.get_user_summary(message.sender_id)
            return {
                'message_id': str(message.id),
                'id': str(message.id),
                'conversation_id': message.conversation_id,
                'sender_id': message.sender_id,
                'sender_name': sender_summary.get("name") or message.sender_id,
                'sender_avatar_url': sender_summary.get("avatar_url"),
                'receiver_id': message.receiver_id,
                'content': message.content,
                'timestamp': message.timestamp.isoformat(),
                'is_read': message.is_read,
            }
        except Exception as e:
            print(f"Error saving message: {str(e)}")
            return None

    @database_sync_to_async
    def mark_messages_as_read(self, conversation_id: str, user_id: str):
        """Mark messages as read asynchronously"""
        try:
            ChatService.mark_messages_as_read(conversation_id, user_id)
        except Exception as e:
            print(f"Error marking messages as read: {str(e)}")

    @database_sync_to_async
    def user_has_access(self, conversation_id: str, user_id: str):
        """Check conversation membership."""
        return ChatService.user_has_conversation_access(conversation_id, user_id)

    @database_sync_to_async
    def get_other_participant(self):
        """Find the other participant from local conversation history."""
        participants = ChatService.get_conversation_participants(
            self.conversation_id,
        )
        for participant in participants:
            if participant != self.user_id:
                return participant
        return None

    @database_sync_to_async
    def mark_user_online(self, user_id: str):
        return PresenceService.mark_online(user_id)

    @database_sync_to_async
    def mark_user_offline(self, user_id: str):
        return PresenceService.mark_offline(user_id)

    async def send_error(self, message: str):
        """Send error message to client"""
        await self.send(text_data=json.dumps({
            'type': 'error',
            'message': message
        }))


class ChatNotificationConsumer(AsyncWebsocketConsumer):
    """User-level websocket for chat notifications across all conversations."""

    async def connect(self):
        self.user_id = self.scope['user'].get('uid') if self.scope.get('user') else None
        if not self.user_id:
            await self.close(code=4001)
            return

        self.group_name = f"user_notifications_{self.user_id}"
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.mark_user_online(self.user_id)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "group_name"):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)
            await self.mark_user_offline(self.user_id)

    async def chat_notification_event(self, event):
        if event.get("sender_id") == self.user_id:
            return

        await self.send(text_data=json.dumps({
            "type": "chat_notification",
            "message_id": event["message_id"],
            "conversation_id": event["conversation_id"],
            "sender_id": event["sender_id"],
            "sender_name": event.get("sender_name") or event["sender_id"],
            "sender_avatar_url": event.get("sender_avatar_url"),
            "receiver_id": event["receiver_id"],
            "content": event["content"],
            "timestamp": event["timestamp"],
            "is_read": event["is_read"],
        }))

    @database_sync_to_async
    def mark_user_online(self, user_id: str):
        return PresenceService.mark_online(user_id)

    @database_sync_to_async
    def mark_user_offline(self, user_id: str):
        return PresenceService.mark_offline(user_id)
