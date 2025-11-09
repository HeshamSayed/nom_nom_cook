"""
Views for the recipes app
"""
from rest_framework import viewsets, status, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q
from django.utils import timezone
from .models import (
    Category, Ingredient, Recipe, RecipeRating, CookSnap,
    RecipeFolder, SavedRecipe, MealPlan, ShoppingList, ShoppingListItem,
    Challenge, ChallengeEntry, RecipeVote
)
from .serializers import (
    CategorySerializer, IngredientSerializer, RecipeListSerializer,
    RecipeDetailSerializer, RecipeCreateUpdateSerializer, RecipeRatingSerializer,
    CookSnapSerializer, RecipeFolderSerializer, SavedRecipeSerializer,
    MealPlanSerializer, ShoppingListSerializer, ShoppingListItemSerializer,
    ChallengeSerializer, ChallengeEntrySerializer, RecipeVoteSerializer
)
from .filters import RecipeFilter


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]


class IngredientViewSet(viewsets.ModelViewSet):
    queryset = Ingredient.objects.all()
    serializer_class = IngredientSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'name_ar']

    @action(detail=False, methods=['get'])
    def common(self, request):
        """Get common Egyptian ingredients"""
        ingredients = self.queryset.filter(is_common=True)
        serializer = self.get_serializer(ingredients, many=True)
        return Response(serializer.data)


class RecipeViewSet(viewsets.ModelViewSet):
    queryset = Recipe.objects.filter(visibility='public')
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = RecipeFilter
    search_fields = ['title', 'title_ar', 'description', 'tags']
    ordering_fields = ['created_at', 'rating_average', 'views_count', 'likes_count']
    ordering = ['-created_at']

    def get_serializer_class(self):
        if self.action == 'list':
            return RecipeListSerializer
        elif self.action in ['create', 'update', 'partial_update']:
            return RecipeCreateUpdateSerializer
        return RecipeDetailSerializer

    def get_queryset(self):
        queryset = super().get_queryset()

        # Filter by dietary preferences
        if self.request.user.is_authenticated:
            preferences = getattr(self.request.user, 'preferences', None)
            if preferences and preferences.dietary_preferences:
                for pref in preferences.dietary_preferences:
                    if pref == 'vegan':
                        queryset = queryset.filter(is_vegan=True)
                    elif pref == 'vegetarian':
                        queryset = queryset.filter(is_vegetarian=True)
                    elif pref == 'keto':
                        queryset = queryset.filter(is_keto=True)
                    elif pref == 'gluten_free':
                        queryset = queryset.filter(is_gluten_free=True)
                    elif pref == 'dairy_free':
                        queryset = queryset.filter(is_dairy_free=True)

        return queryset

    def perform_create(self, serializer):
        recipe = serializer.save(author=self.request.user, published_at=timezone.now())
        # Update user's recipe count
        self.request.user.recipes_count += 1
        self.request.user.save()

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        # Increment view count
        instance.views_count += 1
        instance.save(update_fields=['views_count'])
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Get featured recipes"""
        recipes = self.get_queryset().filter(is_featured=True)
        page = self.paginate_queryset(recipes)

        if page is not None:
            serializer = RecipeListSerializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)

        serializer = RecipeListSerializer(recipes, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def popular(self, request):
        """Get popular recipes (premium feature)"""
        if not request.user.is_premium:
            return Response(
                {'error': 'This feature is only available for premium users'},
                status=status.HTTP_403_FORBIDDEN
            )

        recipes = self.get_queryset().order_by('-rating_average', '-views_count')[:20]
        serializer = RecipeListSerializer(recipes, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def ramadan(self, request):
        """Get Ramadan special recipes (iftar and suhoor)"""
        recipes = self.get_queryset().filter(
            Q(tags__contains=['ramadan']) |
            Q(tags__contains=['iftar']) |
            Q(tags__contains=['suhoor'])
        )
        page = self.paginate_queryset(recipes)

        if page is not None:
            serializer = RecipeListSerializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)

        serializer = RecipeListSerializer(recipes, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        """Like a recipe"""
        recipe = self.get_object()
        from apps.social.models import RecipeLike

        like, created = RecipeLike.objects.get_or_create(
            user=request.user,
            recipe=recipe
        )

        if not created:
            return Response(
                {'error': 'You have already liked this recipe'},
                status=status.HTTP_400_BAD_REQUEST
            )

        recipe.likes_count += 1
        recipe.save(update_fields=['likes_count'])

        return Response({'message': 'Recipe liked successfully'})

    @action(detail=True, methods=['post'])
    def unlike(self, request, pk=None):
        """Unlike a recipe"""
        recipe = self.get_object()
        from apps.social.models import RecipeLike

        try:
            like = RecipeLike.objects.get(user=request.user, recipe=recipe)
            like.delete()

            recipe.likes_count -= 1
            recipe.save(update_fields=['likes_count'])

            return Response({'message': 'Recipe unliked successfully'})
        except RecipeLike.DoesNotExist:
            return Response(
                {'error': 'You have not liked this recipe'},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['post'])
    def save(self, request, pk=None):
        """Save recipe to a folder"""
        recipe = self.get_object()
        folder_id = request.data.get('folder_id')

        folder = None
        if folder_id:
            try:
                folder = RecipeFolder.objects.get(id=folder_id, user=request.user)
            except RecipeFolder.DoesNotExist:
                return Response(
                    {'error': 'Folder not found'},
                    status=status.HTTP_404_NOT_FOUND
                )

        saved_recipe, created = SavedRecipe.objects.get_or_create(
            user=request.user,
            recipe=recipe,
            folder=folder,
            defaults={'notes': request.data.get('notes', '')}
        )

        if not created:
            return Response(
                {'error': 'Recipe already saved'},
                status=status.HTTP_400_BAD_REQUEST
            )

        recipe.saves_count += 1
        recipe.save(update_fields=['saves_count'])

        return Response(
            SavedRecipeSerializer(saved_recipe).data,
            status=status.HTTP_201_CREATED
        )

    @action(detail=True, methods=['delete'])
    def unsave(self, request, pk=None):
        """Remove recipe from saved recipes"""
        recipe = self.get_object()

        try:
            saved_recipe = SavedRecipe.objects.get(user=request.user, recipe=recipe)
            saved_recipe.delete()

            recipe.saves_count -= 1
            recipe.save(update_fields=['saves_count'])

            return Response({'message': 'Recipe unsaved successfully'})
        except SavedRecipe.DoesNotExist:
            return Response(
                {'error': 'Recipe not in saved recipes'},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['post'])
    def rate(self, request, pk=None):
        """Rate a recipe"""
        recipe = self.get_object()
        serializer = RecipeRatingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        rating, created = RecipeRating.objects.update_or_create(
            user=request.user,
            recipe=recipe,
            defaults={
                'rating': serializer.validated_data['rating'],
                'review': serializer.validated_data.get('review', '')
            }
        )

        # Recalculate recipe rating average
        ratings = RecipeRating.objects.filter(recipe=recipe)
        recipe.rating_count = ratings.count()
        recipe.rating_average = sum(r.rating for r in ratings) / recipe.rating_count
        recipe.save(update_fields=['rating_average', 'rating_count'])

        return Response(RecipeRatingSerializer(rating).data)


class RecipeFolderViewSet(viewsets.ModelViewSet):
    serializer_class = RecipeFolderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return RecipeFolder.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class SavedRecipeViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = SavedRecipeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return SavedRecipe.objects.filter(user=self.request.user)


class CookSnapViewSet(viewsets.ModelViewSet):
    serializer_class = CookSnapSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        recipe_id = self.request.query_params.get('recipe_id')
        if recipe_id:
            return CookSnap.objects.filter(recipe_id=recipe_id)
        return CookSnap.objects.all()

    def perform_create(self, serializer):
        cooksnap = serializer.save(user=self.request.user)
        # Update recipe cooksnap count
        cooksnap.recipe.cooksnaps_count += 1
        cooksnap.recipe.save(update_fields=['cooksnaps_count'])

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        """Like a cooksnap"""
        cooksnap = self.get_object()
        from apps.social.models import CookSnapLike

        like, created = CookSnapLike.objects.get_or_create(
            user=request.user,
            cooksnap=cooksnap
        )

        if not created:
            return Response(
                {'error': 'You have already liked this cooksnap'},
                status=status.HTTP_400_BAD_REQUEST
            )

        cooksnap.likes_count += 1
        cooksnap.save(update_fields=['likes_count'])

        return Response({'message': 'CookSnap liked successfully'})

    @action(detail=True, methods=['post'])
    def unlike(self, request, pk=None):
        """Unlike a cooksnap"""
        cooksnap = self.get_object()
        from apps.social.models import CookSnapLike

        try:
            like = CookSnapLike.objects.get(user=request.user, cooksnap=cooksnap)
            like.delete()

            cooksnap.likes_count -= 1
            cooksnap.save(update_fields=['likes_count'])

            return Response({'message': 'CookSnap unliked successfully'})
        except CookSnapLike.DoesNotExist:
            return Response(
                {'error': 'You have not liked this cooksnap'},
                status=status.HTTP_400_BAD_REQUEST
            )


class MealPlanViewSet(viewsets.ModelViewSet):
    serializer_class = MealPlanSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = MealPlan.objects.filter(user=self.request.user)

        # Filter by date range
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        if start_date:
            queryset = queryset.filter(date__gte=start_date)
        if end_date:
            queryset = queryset.filter(date__lte=end_date)

        return queryset.order_by('date', 'meal_type')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['post'])
    def generate_shopping_list(self, request):
        """Generate shopping list from meal plans"""
        start_date = request.data.get('start_date')
        end_date = request.data.get('end_date')

        if not start_date or not end_date:
            return Response(
                {'error': 'start_date and end_date are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        meal_plans = self.get_queryset().filter(
            date__gte=start_date,
            date__lte=end_date
        )

        # Create shopping list
        shopping_list = ShoppingList.objects.create(
            user=request.user,
            name=f"Shopping List {start_date} to {end_date}"
        )

        # Aggregate ingredients from all meal plans
        ingredients_dict = {}
        for meal_plan in meal_plans:
            for recipe_ingredient in meal_plan.recipe.recipe_ingredients.all():
                ingredient_id = recipe_ingredient.ingredient.id
                if ingredient_id in ingredients_dict:
                    # Combine quantities (simplified - would need unit conversion)
                    ingredients_dict[ingredient_id]['quantity'] += f" + {recipe_ingredient.quantity}"
                else:
                    ingredients_dict[ingredient_id] = {
                        'ingredient': recipe_ingredient.ingredient,
                        'quantity': recipe_ingredient.quantity,
                        'unit': recipe_ingredient.unit
                    }

        # Create shopping list items
        for ingredient_data in ingredients_dict.values():
            ShoppingListItem.objects.create(
                shopping_list=shopping_list,
                ingredient=ingredient_data['ingredient'],
                quantity=ingredient_data['quantity'],
                unit=ingredient_data['unit']
            )

        return Response(
            ShoppingListSerializer(shopping_list).data,
            status=status.HTTP_201_CREATED
        )


class ShoppingListViewSet(viewsets.ModelViewSet):
    serializer_class = ShoppingListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ShoppingList.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def add_item(self, request, pk=None):
        """Add item to shopping list"""
        shopping_list = self.get_object()
        serializer = ShoppingListItemSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(shopping_list=shopping_list)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['patch'])
    def toggle_item(self, request, pk=None):
        """Toggle item purchased status"""
        shopping_list = self.get_object()
        item_id = request.data.get('item_id')

        try:
            item = ShoppingListItem.objects.get(id=item_id, shopping_list=shopping_list)
            item.is_purchased = not item.is_purchased
            item.save()
            return Response(ShoppingListItemSerializer(item).data)
        except ShoppingListItem.DoesNotExist:
            return Response(
                {'error': 'Item not found'},
                status=status.HTTP_404_NOT_FOUND
            )


class ChallengeViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for challenges - users can list and retrieve challenges
    """
    queryset = Challenge.objects.all()
    serializer_class = ChallengeSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status']
    ordering_fields = ['start_date', 'participants_count', 'total_votes']
    ordering = ['-start_date']

    @action(detail=True, methods=['get'])
    def entries(self, request, pk=None):
        """Get all entries for a challenge"""
        challenge = self.get_object()
        entries = challenge.entries.select_related('recipe', 'user').all()
        serializer = ChallengeEntrySerializer(
            entries,
            many=True,
            context={'request': request}
        )
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def leaderboard(self, request, pk=None):
        """Get leaderboard (top entries by votes)"""
        challenge = self.get_object()
        entries = challenge.entries.select_related('recipe', 'user').order_by('-votes_count')[:10]
        serializer = ChallengeEntrySerializer(
            entries,
            many=True,
            context={'request': request}
        )
        return Response(serializer.data)


class ChallengeEntryViewSet(viewsets.ModelViewSet):
    """
    ViewSet for challenge entries - users can submit and manage their entries
    """
    queryset = ChallengeEntry.objects.all()
    serializer_class = ChallengeEntrySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        queryset = super().get_queryset()
        challenge_id = self.request.query_params.get('challenge')
        if challenge_id:
            queryset = queryset.filter(challenge_id=challenge_id)
        return queryset.select_related('recipe', 'user', 'challenge')

    def perform_create(self, serializer):
        challenge = serializer.validated_data['challenge']

        # Check if challenge is accepting entries
        if challenge.status != 'active':
            raise serializers.ValidationError('Challenge is not accepting entries')

        # Check if user has reached max entries
        user_entries = ChallengeEntry.objects.filter(
            challenge=challenge,
            user=self.request.user
        ).count()
        if user_entries >= challenge.max_entries_per_user:
            raise serializers.ValidationError(
                f'You can only submit {challenge.max_entries_per_user} entry(ies) per challenge'
            )

        # Check if recipe is already submitted
        if ChallengeEntry.objects.filter(
            challenge=challenge,
            recipe=serializer.validated_data['recipe']
        ).exists():
            raise serializers.ValidationError('This recipe is already submitted to this challenge')

        serializer.save(user=self.request.user)


class RecipeVoteViewSet(viewsets.ModelViewSet):
    """
    ViewSet for voting on challenge entries
    """
    queryset = RecipeVote.objects.all()
    serializer_class = RecipeVoteSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'delete']

    def get_queryset(self):
        queryset = super().get_queryset()
        challenge_id = self.request.query_params.get('challenge')
        if challenge_id:
            queryset = queryset.filter(challenge_id=challenge_id)
        return queryset.select_related('entry', 'user', 'challenge')

    def perform_create(self, serializer):
        challenge = serializer.validated_data['challenge']

        # Check if challenge is in voting phase
        if challenge.status != 'voting':
            raise serializers.ValidationError('Challenge is not in voting phase')

        # Check if user already voted
        if RecipeVote.objects.filter(
            challenge=challenge,
            user=self.request.user
        ).exists():
            raise serializers.ValidationError('You have already voted in this challenge')

        # Check if user is voting for their own entry
        entry = serializer.validated_data['entry']
        if entry.user == self.request.user:
            raise serializers.ValidationError('You cannot vote for your own entry')

        serializer.save(user=self.request.user)

    @action(detail=False, methods=['delete'])
    def remove_vote(self, request):
        """Remove user's vote from a challenge"""
        challenge_id = request.data.get('challenge_id')
        if not challenge_id:
            return Response(
                {'error': 'challenge_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            vote = RecipeVote.objects.get(
                challenge_id=challenge_id,
                user=request.user
            )

            # Update counts
            entry = vote.entry
            entry.votes_count = max(0, entry.votes_count - 1)
            entry.save()

            challenge = vote.challenge
            challenge.total_votes = max(0, challenge.total_votes - 1)
            challenge.save()

            vote.delete()

            return Response(
                {'message': 'Vote removed successfully'},
                status=status.HTTP_204_NO_CONTENT
            )
        except RecipeVote.DoesNotExist:
            return Response(
                {'error': 'Vote not found'},
                status=status.HTTP_404_NOT_FOUND
            )
