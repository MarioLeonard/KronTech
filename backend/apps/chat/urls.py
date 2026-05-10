from django.urls import path
from . import views

app_name = 'chat'

urlpatterns = [
    # Conversation endpoints
    path('conversations/', views.ConversationListView.as_view(), name='conversation-list'),
    
    # Message endpoints
    path('conversations/<str:conversation_id>/messages/', 
         views.MessageListView.as_view(), 
         name='message-list'),
    path('conversations/<str:receiver_id>/send/', 
         views.SendMessageView.as_view(), 
         name='send-message'),
    path('conversations/<str:conversation_id>/mark-read/', 
         views.MarkMessagesAsReadView.as_view(), 
         name='mark-read'),
]
