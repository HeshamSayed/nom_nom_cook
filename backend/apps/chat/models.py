"""
Real-time chat models for Cookpad Egypt
"""
from django.db import models
from django.utils.translation import gettext_lazy as _
from apps.users.models import User


class ChatRoom(models.Model):
    """
    Chat rooms between users
    """
    ROOM_TYPES = [
        ('direct', 'Direct Message'),
        ('group', 'Group Chat'),
    ]

    room_type = models.CharField(_('room type'), max_length=10, choices=ROOM_TYPES, default='direct')
    name = models.CharField(_('name'), max_length=200, blank=True)
    participants = models.ManyToManyField(
        User,
        related_name='chat_rooms'
    )
    created_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        related_name='created_chat_rooms'
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('chat room')
        verbose_name_plural = _('chat rooms')
        ordering = ['-updated_at']

    def __str__(self):
        if self.room_type == 'direct':
            participants = list(self.participants.all()[:2])
            if len(participants) == 2:
                return f"{participants[0].username} & {participants[1].username}"
        return self.name or f"Chat Room {self.id}"


class Message(models.Model):
    """
    Chat messages
    """
    MESSAGE_TYPES = [
        ('text', 'Text'),
        ('image', 'Image'),
        ('recipe', 'Recipe Share'),
    ]

    room = models.ForeignKey(
        ChatRoom,
        on_delete=models.CASCADE,
        related_name='messages'
    )
    sender = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    message_type = models.CharField(_('message type'), max_length=10, choices=MESSAGE_TYPES, default='text')
    content = models.TextField(_('content'), blank=True)
    image = models.ImageField(_('image'), upload_to='chat_images/', blank=True, null=True)

    # For recipe sharing
    shared_recipe_id = models.PositiveIntegerField(_('shared recipe ID'), null=True, blank=True)

    is_read = models.BooleanField(_('is read'), default=False)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('message')
        verbose_name_plural = _('messages')
        ordering = ['created_at']

    def __str__(self):
        return f"{self.sender.username}: {self.content[:50]}"


class MessageReadReceipt(models.Model):
    """
    Track message read status per user
    """
    message = models.ForeignKey(
        Message,
        on_delete=models.CASCADE,
        related_name='read_receipts'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='message_read_receipts'
    )
    read_at = models.DateTimeField(_('read at'), auto_now_add=True)

    class Meta:
        verbose_name = _('message read receipt')
        verbose_name_plural = _('message read receipts')
        unique_together = ('message', 'user')
        ordering = ['-read_at']

    def __str__(self):
        return f"{self.user.username} read message {self.message.id}"
