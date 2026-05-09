from rest_framework import serializers
from .models import Message


class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = [
            'id',
            'sender_id',
            'receiver_id',
            'content',
            'timestamp',
            'is_read',
            'conversation_id'
        ]
        read_only_fields = ['id', 'timestamp', 'conversation_id']
