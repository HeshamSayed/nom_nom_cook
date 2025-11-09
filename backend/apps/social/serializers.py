"""
Serializers for the social app
"""
from rest_framework import serializers
from .models import RecipeLike, CookSnapLike, Comment, CommentLike, Notification, Report
from apps.users.serializers import UserSerializer
from apps.recipes.serializers import RecipeListSerializer


class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    replies = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = [
            'id', 'user', 'recipe', 'parent', 'text', 'likes_count',
            'created_at', 'updated_at', 'replies', 'is_liked'
        ]
        read_only_fields = ['id', 'likes_count', 'created_at', 'updated_at']

    def get_replies(self, obj):
        if obj.parent is None:  # Only get replies for top-level comments
            replies = obj.replies.all()
            return CommentSerializer(replies, many=True, context=self.context).data
        return []

    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return CommentLike.objects.filter(
                user=request.user,
                comment=obj
            ).exists()
        return False


class NotificationSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    related_recipe = RecipeListSerializer(read_only=True)

    class Meta:
        model = Notification
        fields = [
            'id', 'sender', 'notification_type', 'title', 'message',
            'related_recipe', 'related_comment', 'is_read', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class ReportSerializer(serializers.ModelSerializer):
    reporter = UserSerializer(read_only=True)
    resolved_by = UserSerializer(read_only=True)

    class Meta:
        model = Report
        fields = [
            'id', 'reporter', 'reported_recipe', 'reported_comment',
            'reported_user', 'report_type', 'description', 'is_resolved',
            'resolved_by', 'resolution_notes', 'created_at', 'resolved_at'
        ]
        read_only_fields = ['id', 'reporter', 'created_at', 'resolved_at']
