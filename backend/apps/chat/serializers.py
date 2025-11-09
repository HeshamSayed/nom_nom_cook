"""
Serializers for the chat app
"""
from rest_framework import serializers
from .models import ChatRoom, Message, MessageReadReceipt
from apps.users.serializers import UserSerializer


class ChatRoomSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = [
            'id', 'room_type', 'name', 'participants', 'last_message',
            'unread_count', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_last_message(self, obj):
        last_message = obj.messages.order_by('-created_at').first()
        if last_message:
            return MessageSerializer(last_message).data
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.messages.filter(
                is_read=False
            ).exclude(sender=request.user).count()
        return 0


class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    is_read = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'id', 'room', 'sender', 'message_type', 'content', 'image',
            'shared_recipe_id', 'is_read', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def get_is_read(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return MessageReadReceipt.objects.filter(
                message=obj,
                user=request.user
            ).exists()
        return False
