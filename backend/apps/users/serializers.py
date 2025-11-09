"""
Serializers for the users app
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import UserPreferences, Follow

User = get_user_model()


class UserPreferencesSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserPreferences
        fields = [
            'dietary_preferences', 'allergies', 'disliked_ingredients',
            'preferred_cuisines', 'skill_level', 'email_notifications',
            'push_notifications', 'new_follower_notification',
            'recipe_like_notification', 'comment_notification'
        ]


class UserSerializer(serializers.ModelSerializer):
    preferences = UserPreferencesSerializer(read_only=True)
    is_following = serializers.SerializerMethodField()
    is_follower = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'phone_number', 'avatar', 'bio', 'location',
            'preferred_language', 'is_premium', 'premium_since',
            'followers_count', 'following_count', 'recipes_count',
            'created_at', 'preferences', 'is_following', 'is_follower'
        ]
        read_only_fields = [
            'id', 'is_premium', 'premium_since', 'followers_count',
            'following_count', 'recipes_count', 'created_at'
        ]

    def get_is_following(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Follow.objects.filter(
                follower=request.user,
                following=obj
            ).exists()
        return False

    def get_is_follower(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Follow.objects.filter(
                follower=obj,
                following=request.user
            ).exists()
        return False


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'password_confirm',
            'first_name', 'last_name', 'preferred_language'
        ]

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password": "Passwords must match"})
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        # Create user preferences
        UserPreferences.objects.create(user=user)
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'username', 'first_name', 'last_name', 'phone_number',
            'avatar', 'bio', 'location', 'preferred_language'
        ]


class FollowSerializer(serializers.ModelSerializer):
    follower = UserSerializer(read_only=True)
    following = UserSerializer(read_only=True)

    class Meta:
        model = Follow
        fields = ['id', 'follower', 'following', 'created_at']
        read_only_fields = ['id', 'created_at']


class FollowerListSerializer(serializers.ModelSerializer):
    user = UserSerializer(source='follower', read_only=True)

    class Meta:
        model = Follow
        fields = ['id', 'user', 'created_at']


class FollowingListSerializer(serializers.ModelSerializer):
    user = UserSerializer(source='following', read_only=True)

    class Meta:
        model = Follow
        fields = ['id', 'user', 'created_at']
