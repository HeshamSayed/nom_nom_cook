"""
User models for Cookpad Egypt
"""
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _


class User(AbstractUser):
    """
    Custom User model extending Django's AbstractUser
    """
    LANGUAGE_CHOICES = [
        ('en', 'English'),
        ('ar', 'Arabic'),
    ]

    email = models.EmailField(_('email address'), unique=True)
    phone_number = models.CharField(_('phone number'), max_length=20, blank=True, null=True)
    avatar = models.ImageField(_('avatar'), upload_to='avatars/', blank=True, null=True)
    bio = models.TextField(_('bio'), max_length=500, blank=True)
    location = models.CharField(_('location'), max_length=100, blank=True)
    preferred_language = models.CharField(
        _('preferred language'),
        max_length=2,
        choices=LANGUAGE_CHOICES,
        default='ar'
    )

    # Premium subscription
    is_premium = models.BooleanField(_('premium subscriber'), default=False)
    premium_since = models.DateTimeField(_('premium since'), blank=True, null=True)

    # Social stats
    followers_count = models.PositiveIntegerField(_('followers count'), default=0)
    following_count = models.PositiveIntegerField(_('following count'), default=0)
    recipes_count = models.PositiveIntegerField(_('recipes count'), default=0)

    # Timestamps
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-created_at']

    def __str__(self):
        return self.email


class UserPreferences(models.Model):
    """
    User dietary preferences and cooking settings
    """
    DIET_CHOICES = [
        ('none', 'No Preference'),
        ('vegan', 'Vegan'),
        ('vegetarian', 'Vegetarian'),
        ('keto', 'Keto'),
        ('gluten_free', 'Gluten Free'),
        ('dairy_free', 'Dairy Free'),
        ('halal', 'Halal'),
    ]

    SKILL_LEVEL_CHOICES = [
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced'),
        ('expert', 'Expert'),
    ]

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='preferences'
    )
    dietary_preferences = models.JSONField(
        _('dietary preferences'),
        default=list,
        help_text=_('List of dietary preferences')
    )
    allergies = models.JSONField(
        _('allergies'),
        default=list,
        help_text=_('List of food allergies')
    )
    disliked_ingredients = models.JSONField(
        _('disliked ingredients'),
        default=list,
        help_text=_('List of disliked ingredients')
    )
    preferred_cuisines = models.JSONField(
        _('preferred cuisines'),
        default=list,
        help_text=_('List of preferred cuisines (e.g., Egyptian, Italian, Thai)')
    )
    skill_level = models.CharField(
        _('skill level'),
        max_length=20,
        choices=SKILL_LEVEL_CHOICES,
        default='beginner'
    )

    # Notification preferences
    email_notifications = models.BooleanField(_('email notifications'), default=True)
    push_notifications = models.BooleanField(_('push notifications'), default=True)
    new_follower_notification = models.BooleanField(_('new follower notification'), default=True)
    recipe_like_notification = models.BooleanField(_('recipe like notification'), default=True)
    comment_notification = models.BooleanField(_('comment notification'), default=True)

    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('user preference')
        verbose_name_plural = _('user preferences')

    def __str__(self):
        return f"{self.user.email}'s preferences"


class Follow(models.Model):
    """
    Model for user following relationships
    """
    follower = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='following'
    )
    following = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='followers'
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('follow')
        verbose_name_plural = _('follows')
        unique_together = ('follower', 'following')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.follower.username} follows {self.following.username}"
