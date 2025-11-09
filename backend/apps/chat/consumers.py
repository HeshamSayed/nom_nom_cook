"""
WebSocket consumers for real-time chat
"""
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import ChatRoom, Message

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    # Receive message from WebSocket
    async def receive(self, text_data):
        data = json.loads(text_data)
        message_type = data.get('type', 'text')
        content = data.get('content', '')
        sender_id = data.get('sender_id')

        # Save message to database
        message = await self.save_message(
            room_id=self.room_id,
            sender_id=sender_id,
            message_type=message_type,
            content=content
        )

        # Send message to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': {
                    'id': message.id,
                    'sender_id': sender_id,
                    'sender_username': message.sender.username,
                    'message_type': message_type,
                    'content': content,
                    'created_at': message.created_at.isoformat(),
                }
            }
        )

    # Receive message from room group
    async def chat_message(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'message': message
        }))

    @database_sync_to_async
    def save_message(self, room_id, sender_id, message_type, content):
        room = ChatRoom.objects.get(id=room_id)
        sender = User.objects.get(id=sender_id)
        message = Message.objects.create(
            room=room,
            sender=sender,
            message_type=message_type,
            content=content
        )
        return message
