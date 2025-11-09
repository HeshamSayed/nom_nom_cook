from django.contrib import admin
from .models import ChatRoom, Message, MessageReadReceipt


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ('id', 'room_type', 'name', 'created_by', 'created_at')
    list_filter = ('room_type', 'created_at')
    search_fields = ('name',)
    filter_horizontal = ('participants',)


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ('sender', 'room', 'message_type', 'content', 'is_read', 'created_at')
    list_filter = ('message_type', 'is_read', 'created_at')
    search_fields = ('sender__email', 'content')


@admin.register(MessageReadReceipt)
class MessageReadReceiptAdmin(admin.ModelAdmin):
    list_display = ('user', 'message', 'read_at')
    list_filter = ('read_at',)
    search_fields = ('user__email',)
