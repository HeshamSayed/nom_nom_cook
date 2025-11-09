"""
Views for the users app
"""
from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from .models import UserPreferences, Follow
from .serializers import (
    UserSerializer, UserCreateSerializer, UserUpdateSerializer,
    UserPreferencesSerializer, FollowSerializer, FollowerListSerializer,
    FollowingListSerializer
)

User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_serializer_class(self):
        if self.action == 'create':
            return UserCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return UserUpdateSerializer
        return UserSerializer

    def get_permissions(self):
        if self.action == 'create':
            return [permissions.AllowAny()]
        return super().get_permissions()

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)

        return Response({
            'user': UserSerializer(user).data,
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }
        }, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get', 'put', 'patch'])
    def me(self, request):
        """Get or update current user profile"""
        if request.method == 'GET':
            serializer = self.get_serializer(request.user)
            return Response(serializer.data)
        else:
            serializer = UserUpdateSerializer(
                request.user,
                data=request.data,
                partial=request.method == 'PATCH'
            )
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(UserSerializer(request.user).data)

    @action(detail=True, methods=['post'])
    def follow(self, request, pk=None):
        """Follow a user"""
        user_to_follow = self.get_object()

        if user_to_follow == request.user:
            return Response(
                {'error': 'You cannot follow yourself'},
                status=status.HTTP_400_BAD_REQUEST
            )

        follow, created = Follow.objects.get_or_create(
            follower=request.user,
            following=user_to_follow
        )

        if not created:
            return Response(
                {'error': 'You are already following this user'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Update follower counts
        request.user.following_count += 1
        request.user.save()
        user_to_follow.followers_count += 1
        user_to_follow.save()

        return Response(
            {'message': 'Successfully followed user'},
            status=status.HTTP_201_CREATED
        )

    @action(detail=True, methods=['post'])
    def unfollow(self, request, pk=None):
        """Unfollow a user"""
        user_to_unfollow = self.get_object()

        try:
            follow = Follow.objects.get(
                follower=request.user,
                following=user_to_unfollow
            )
            follow.delete()

            # Update follower counts
            request.user.following_count -= 1
            request.user.save()
            user_to_unfollow.followers_count -= 1
            user_to_unfollow.save()

            return Response(
                {'message': 'Successfully unfollowed user'},
                status=status.HTTP_200_OK
            )
        except Follow.DoesNotExist:
            return Response(
                {'error': 'You are not following this user'},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['get'])
    def followers(self, request, pk=None):
        """Get user's followers"""
        user = self.get_object()
        followers = Follow.objects.filter(following=user)
        page = self.paginate_queryset(followers)

        if page is not None:
            serializer = FollowerListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = FollowerListSerializer(followers, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def following(self, request, pk=None):
        """Get users that this user is following"""
        user = self.get_object()
        following = Follow.objects.filter(follower=user)
        page = self.paginate_queryset(following)

        if page is not None:
            serializer = FollowingListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = FollowingListSerializer(following, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def recipes(self, request, pk=None):
        """Get user's recipes"""
        user = self.get_object()
        from apps.recipes.models import Recipe
        from apps.recipes.serializers import RecipeListSerializer

        recipes = Recipe.objects.filter(author=user, visibility='public')
        page = self.paginate_queryset(recipes)

        if page is not None:
            serializer = RecipeListSerializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)

        serializer = RecipeListSerializer(recipes, many=True, context={'request': request})
        return Response(serializer.data)


class UserPreferencesViewSet(viewsets.ModelViewSet):
    serializer_class = UserPreferencesSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return UserPreferences.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['get', 'put', 'patch'])
    def me(self, request):
        """Get or update current user preferences"""
        preferences, created = UserPreferences.objects.get_or_create(
            user=request.user
        )

        if request.method == 'GET':
            serializer = self.get_serializer(preferences)
            return Response(serializer.data)
        else:
            serializer = self.get_serializer(
                preferences,
                data=request.data,
                partial=request.method == 'PATCH'
            )
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)
