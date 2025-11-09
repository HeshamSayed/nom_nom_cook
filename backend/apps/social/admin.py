from django.contrib import admin
from .models import RecipeLike, CookSnapLike, Comment, CommentLike, Notification, Report


@admin.register(RecipeLike)
class RecipeLikeAdmin(admin.ModelAdmin):
    list_display = ('user', 'recipe', 'created_at')
    search_fields = ('user__email', 'recipe__title')


@admin.register(CookSnapLike)
class CookSnapLikeAdmin(admin.ModelAdmin):
    list_display = ('user', 'cooksnap', 'created_at')
    search_fields = ('user__email',)


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ('user', 'recipe', 'text', 'likes_count', 'created_at')
    search_fields = ('user__email', 'recipe__title', 'text')
    list_filter = ('created_at',)


@admin.register(CommentLike)
class CommentLikeAdmin(admin.ModelAdmin):
    list_display = ('user', 'comment', 'created_at')
    search_fields = ('user__email',)


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('recipient', 'sender', 'notification_type', 'title', 'is_read', 'created_at')
    list_filter = ('notification_type', 'is_read', 'created_at')
    search_fields = ('recipient__email', 'sender__email', 'title')


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ('reporter', 'report_type', 'is_resolved', 'created_at')
    list_filter = ('report_type', 'is_resolved', 'created_at')
    search_fields = ('reporter__email', 'description')
