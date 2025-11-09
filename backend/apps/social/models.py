"""
Social interaction models for Cookpad Egypt
"""
from django.db import models
from django.utils.translation import gettext_lazy as _
from apps.users.models import User
from apps.recipes.models import Recipe, CookSnap


class RecipeLike(models.Model):
    """
    Users liking recipes
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='recipe_likes'
    )
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='likes'
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('recipe like')
        verbose_name_plural = _('recipe likes')
        unique_together = ('user', 'recipe')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} likes {self.recipe.title}"


class CookSnapLike(models.Model):
    """
    Users liking cooksnaps
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='cooksnap_likes'
    )
    cooksnap = models.ForeignKey(
        CookSnap,
        on_delete=models.CASCADE,
        related_name='likes'
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('cooksnap like')
        verbose_name_plural = _('cooksnap likes')
        unique_together = ('user', 'cooksnap')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} likes cooksnap"


class Comment(models.Model):
    """
    Comments on recipes
    """
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='comments'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='comments'
    )
    parent = models.ForeignKey(
        'self',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='replies'
    )
    text = models.TextField(_('comment'))
    likes_count = models.PositiveIntegerField(_('likes count'), default=0)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('comment')
        verbose_name_plural = _('comments')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} commented on {self.recipe.title}"


class CommentLike(models.Model):
    """
    Users liking comments
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='comment_likes'
    )
    comment = models.ForeignKey(
        Comment,
        on_delete=models.CASCADE,
        related_name='likes'
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('comment like')
        verbose_name_plural = _('comment likes')
        unique_together = ('user', 'comment')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} likes comment"


class Notification(models.Model):
    """
    User notifications
    """
    NOTIFICATION_TYPES = [
        ('follow', 'New Follower'),
        ('recipe_like', 'Recipe Like'),
        ('cooksnap_like', 'CookSnap Like'),
        ('comment', 'Comment'),
        ('comment_reply', 'Comment Reply'),
        ('comment_like', 'Comment Like'),
        ('recipe_featured', 'Recipe Featured'),
        ('subscription_expiring', 'Subscription Expiring'),
    ]

    recipient = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    sender = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sent_notifications',
        null=True,
        blank=True
    )
    notification_type = models.CharField(
        _('type'),
        max_length=30,
        choices=NOTIFICATION_TYPES
    )
    title = models.CharField(_('title'), max_length=200)
    message = models.TextField(_('message'))
    related_recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications'
    )
    related_comment = models.ForeignKey(
        Comment,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications'
    )
    is_read = models.BooleanField(_('is read'), default=False)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('notification')
        verbose_name_plural = _('notifications')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient', '-created_at']),
            models.Index(fields=['recipient', 'is_read']),
        ]

    def __str__(self):
        return f"Notification for {self.recipient.username}: {self.title}"


class Report(models.Model):
    """
    User reports for inappropriate content
    """
    REPORT_TYPES = [
        ('spam', 'Spam'),
        ('inappropriate', 'Inappropriate Content'),
        ('copyright', 'Copyright Violation'),
        ('misleading', 'Misleading Information'),
        ('harassment', 'Harassment'),
        ('other', 'Other'),
    ]

    reporter = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='reports_made'
    )
    reported_recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='reports'
    )
    reported_comment = models.ForeignKey(
        Comment,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='reports'
    )
    reported_user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='reports_received'
    )
    report_type = models.CharField(_('report type'), max_length=20, choices=REPORT_TYPES)
    description = models.TextField(_('description'))
    is_resolved = models.BooleanField(_('is resolved'), default=False)
    resolved_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reports_resolved'
    )
    resolution_notes = models.TextField(_('resolution notes'), blank=True)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    resolved_at = models.DateTimeField(_('resolved at'), null=True, blank=True)

    class Meta:
        verbose_name = _('report')
        verbose_name_plural = _('reports')
        ordering = ['-created_at']

    def __str__(self):
        return f"Report by {self.reporter.username}"
