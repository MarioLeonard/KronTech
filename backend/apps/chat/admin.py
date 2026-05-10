from django.contrib import admin
from .models import Message


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ('sender_id', 'receiver_id', 'timestamp', 'is_read')
    list_filter = ('is_read', 'timestamp')
    search_fields = ('sender_id', 'receiver_id', 'conversation_id')
    readonly_fields = ('timestamp', 'conversation_id')
    ordering = ('-timestamp',)
