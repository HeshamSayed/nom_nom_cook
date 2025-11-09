from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, UserPreferences, Follow


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('email', 'username', 'is_premium', 'recipes_count', 'followers_count', 'created_at')
    list_filter = ('is_premium', 'is_staff', 'is_active', 'preferred_language')
    search_fields = ('email', 'username', 'phone_number')
    ordering = ('-created_at',)

    fieldsets = BaseUserAdmin.fieldsets + (
        ('Additional Info', {
            'fields': ('phone_number', 'avatar', 'bio', 'location', 'preferred_language')
        }),
        ('Premium', {
            'fields': ('is_premium', 'premium_since')
        }),
        ('Stats', {
            'fields': ('followers_count', 'following_count', 'recipes_count')
        }),
    )


@admin.register(UserPreferences)
class UserPreferencesAdmin(admin.ModelAdmin):
    list_display = ('user', 'skill_level', 'email_notifications', 'push_notifications')
    list_filter = ('skill_level', 'email_notifications', 'push_notifications')
    search_fields = ('user__email', 'user__username')


@admin.register(Follow)
class FollowAdmin(admin.ModelAdmin):
    list_display = ('follower', 'following', 'created_at')
    search_fields = ('follower__email', 'following__email')
    list_filter = ('created_at',)
