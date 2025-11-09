"""
Views for the chat app
"""
from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from .models import ChatRoom, Message, MessageReadReceipt
from .serializers import ChatRoomSerializer, MessageSerializer


class ChatRoomViewSet(viewsets.ModelViewSet):
    serializer_class = ChatRoomSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ChatRoom.objects.filter(participants=self.request.user)

    @action(detail=False, methods=['post'])
    def create_direct(self, request):
        """Create or get existing direct chat room with another user"""
        other_user_id = request.data.get('user_id')

        if not other_user_id:
            return Response(
                {'error': 'user_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        from django.contrib.auth import get_user_model
        User = get_user_model()

        try:
            other_user = User.objects.get(id=other_user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        # Check if direct chat room already exists
        existing_room = ChatRoom.objects.filter(
            room_type='direct',
            participants=request.user
        ).filter(
            participants=other_user
        ).first()

        if existing_room:
            serializer = self.get_serializer(existing_room)
            return Response(serializer.data)

        # Create new direct chat room
        room = ChatRoom.objects.create(
            room_type='direct',
            created_by=request.user
        )
        room.participants.add(request.user, other_user)

        serializer = self.get_serializer(room)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class MessageViewSet(viewsets.ModelViewSet):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        room_id = self.request.query_params.get('room_id')
        if room_id:
            # Verify user is participant in the room
            room = ChatRoom.objects.filter(
                id=room_id,
                participants=self.request.user
            ).first()

            if room:
                return Message.objects.filter(room=room).order_by('created_at')

        return Message.objects.none()

    def perform_create(self, serializer):
        message = serializer.save(sender=self.request.user)

        # Update room's updated_at timestamp
        message.room.save()

    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Mark message as read"""
        message = self.get_object()

        receipt, created = MessageReadReceipt.objects.get_or_create(
            message=message,
            user=request.user
        )

        message.is_read = True
        message.save()

        return Response({'message': 'Message marked as read'})
