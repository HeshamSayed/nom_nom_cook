"""
Views for the social app
"""
from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Comment, Notification, Report
from .serializers import CommentSerializer, NotificationSerializer, ReportSerializer


class CommentViewSet(viewsets.ModelViewSet):
    serializer_class = CommentSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        recipe_id = self.request.query_params.get('recipe_id')
        if recipe_id:
            # Only get top-level comments (replies are nested in serializer)
            return Comment.objects.filter(recipe_id=recipe_id, parent=None)
        return Comment.objects.filter(parent=None)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        """Like a comment"""
        comment = self.get_object()
        from .models import CommentLike

        like, created = CommentLike.objects.get_or_create(
            user=request.user,
            comment=comment
        )

        if not created:
            return Response(
                {'error': 'You have already liked this comment'},
                status=status.HTTP_400_BAD_REQUEST
            )

        comment.likes_count += 1
        comment.save(update_fields=['likes_count'])

        return Response({'message': 'Comment liked successfully'})

    @action(detail=True, methods=['post'])
    def unlike(self, request, pk=None):
        """Unlike a comment"""
        comment = self.get_object()
        from .models import CommentLike

        try:
            like = CommentLike.objects.get(user=request.user, comment=comment)
            like.delete()

            comment.likes_count -= 1
            comment.save(update_fields=['likes_count'])

            return Response({'message': 'Comment unliked successfully'})
        except CommentLike.DoesNotExist:
            return Response(
                {'error': 'You have not liked this comment'},
                status=status.HTTP_400_BAD_REQUEST
            )


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user)

    @action(detail=False, methods=['get'])
    def unread(self, request):
        """Get unread notifications"""
        notifications = self.get_queryset().filter(is_read=False)
        serializer = self.get_serializer(notifications, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications"""
        count = self.get_queryset().filter(is_read=False).count()
        return Response({'count': count})

    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Mark notification as read"""
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'message': 'Notification marked as read'})

    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        """Mark all notifications as read"""
        self.get_queryset().filter(is_read=False).update(is_read=True)
        return Response({'message': 'All notifications marked as read'})


class ReportViewSet(viewsets.ModelViewSet):
    serializer_class = ReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.is_staff:
            return Report.objects.all()
        return Report.objects.filter(reporter=self.request.user)

    def perform_create(self, serializer):
        serializer.save(reporter=self.request.user)
