"""
Serializers for the recipes app
"""
from rest_framework import serializers
from .models import (
    Category, Ingredient, Recipe, RecipeIngredient, RecipeStep,
    RecipeImage, RecipeRating, CookSnap, RecipeFolder, SavedRecipe,
    MealPlan, ShoppingList, ShoppingListItem
)
from apps.users.serializers import UserSerializer


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'name_ar', 'slug', 'description', 'icon', 'order']


class IngredientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ingredient
        fields = ['id', 'name', 'name_ar', 'is_common']


class RecipeIngredientSerializer(serializers.ModelSerializer):
    ingredient = IngredientSerializer(read_only=True)
    ingredient_id = serializers.PrimaryKeyRelatedField(
        queryset=Ingredient.objects.all(),
        source='ingredient',
        write_only=True
    )

    class Meta:
        model = RecipeIngredient
        fields = ['id', 'ingredient', 'ingredient_id', 'quantity', 'unit', 'notes', 'order']


class RecipeStepSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecipeStep
        fields = ['id', 'step_number', 'instruction', 'instruction_ar', 'image', 'duration']


class RecipeImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecipeImage
        fields = ['id', 'image', 'caption', 'order']


class RecipeRatingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = RecipeRating
        fields = ['id', 'user', 'rating', 'review', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']


class CookSnapSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = CookSnap
        fields = ['id', 'user', 'image', 'caption', 'likes_count', 'created_at', 'is_liked']
        read_only_fields = ['id', 'likes_count', 'created_at']

    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            from apps.social.models import CookSnapLike
            return CookSnapLike.objects.filter(
                user=request.user,
                cooksnap=obj
            ).exists()
        return False


class RecipeListSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()

    class Meta:
        model = Recipe
        fields = [
            'id', 'title', 'title_ar', 'description', 'author', 'category',
            'main_image', 'prep_time', 'cook_time', 'servings', 'difficulty',
            'is_vegan', 'is_vegetarian', 'is_gluten_free', 'is_dairy_free',
            'is_keto', 'is_halal', 'rating_average', 'rating_count',
            'views_count', 'likes_count', 'saves_count', 'cooksnaps_count',
            'is_featured', 'created_at', 'is_liked', 'is_saved'
        ]

    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            from apps.social.models import RecipeLike
            return RecipeLike.objects.filter(
                user=request.user,
                recipe=obj
            ).exists()
        return False

    def get_is_saved(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return SavedRecipe.objects.filter(
                user=request.user,
                recipe=obj
            ).exists()
        return False


class RecipeDetailSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    recipe_ingredients = RecipeIngredientSerializer(many=True, read_only=True)
    steps = RecipeStepSerializer(many=True, read_only=True)
    images = RecipeImageSerializer(many=True, read_only=True)
    ratings = RecipeRatingSerializer(many=True, read_only=True)
    cooksnaps = CookSnapSerializer(many=True, read_only=True)
    is_liked = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()
    user_rating = serializers.SerializerMethodField()

    class Meta:
        model = Recipe
        fields = [
            'id', 'title', 'title_ar', 'description', 'description_ar',
            'author', 'category', 'tags', 'prep_time', 'cook_time',
            'servings', 'difficulty', 'is_vegan', 'is_vegetarian',
            'is_gluten_free', 'is_dairy_free', 'is_keto', 'is_halal',
            'calories', 'protein', 'carbs', 'fat', 'main_image',
            'recipe_ingredients', 'steps', 'images', 'ratings', 'cooksnaps',
            'views_count', 'likes_count', 'saves_count', 'cooksnaps_count',
            'rating_average', 'rating_count', 'visibility', 'is_featured',
            'is_premium_only', 'created_at', 'updated_at', 'published_at',
            'is_liked', 'is_saved', 'user_rating'
        ]

    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            from apps.social.models import RecipeLike
            return RecipeLike.objects.filter(
                user=request.user,
                recipe=obj
            ).exists()
        return False

    def get_is_saved(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return SavedRecipe.objects.filter(
                user=request.user,
                recipe=obj
            ).exists()
        return False

    def get_user_rating(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            rating = RecipeRating.objects.filter(
                user=request.user,
                recipe=obj
            ).first()
            if rating:
                return RecipeRatingSerializer(rating).data
        return None


class RecipeCreateUpdateSerializer(serializers.ModelSerializer):
    ingredients = RecipeIngredientSerializer(many=True, required=False)
    steps = RecipeStepSerializer(many=True, required=False)
    images = RecipeImageSerializer(many=True, required=False)

    class Meta:
        model = Recipe
        fields = [
            'title', 'title_ar', 'description', 'description_ar',
            'category', 'tags', 'prep_time', 'cook_time', 'servings',
            'difficulty', 'is_vegan', 'is_vegetarian', 'is_gluten_free',
            'is_dairy_free', 'is_keto', 'is_halal', 'calories', 'protein',
            'carbs', 'fat', 'main_image', 'visibility', 'ingredients',
            'steps', 'images'
        ]

    def create(self, validated_data):
        ingredients_data = validated_data.pop('ingredients', [])
        steps_data = validated_data.pop('steps', [])
        images_data = validated_data.pop('images', [])

        recipe = Recipe.objects.create(**validated_data)

        # Create ingredients
        for ingredient_data in ingredients_data:
            RecipeIngredient.objects.create(recipe=recipe, **ingredient_data)

        # Create steps
        for step_data in steps_data:
            RecipeStep.objects.create(recipe=recipe, **step_data)

        # Create images
        for image_data in images_data:
            RecipeImage.objects.create(recipe=recipe, **image_data)

        return recipe

    def update(self, instance, validated_data):
        ingredients_data = validated_data.pop('ingredients', None)
        steps_data = validated_data.pop('steps', None)
        images_data = validated_data.pop('images', None)

        # Update recipe fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Update ingredients if provided
        if ingredients_data is not None:
            instance.recipe_ingredients.all().delete()
            for ingredient_data in ingredients_data:
                RecipeIngredient.objects.create(recipe=instance, **ingredient_data)

        # Update steps if provided
        if steps_data is not None:
            instance.steps.all().delete()
            for step_data in steps_data:
                RecipeStep.objects.create(recipe=instance, **step_data)

        # Update images if provided
        if images_data is not None:
            instance.images.all().delete()
            for image_data in images_data:
                RecipeImage.objects.create(recipe=instance, **image_data)

        return instance


class RecipeFolderSerializer(serializers.ModelSerializer):
    recipes_count = serializers.SerializerMethodField()

    class Meta:
        model = RecipeFolder
        fields = ['id', 'name', 'description', 'is_private', 'recipes_count', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_recipes_count(self, obj):
        return obj.recipes.count()


class SavedRecipeSerializer(serializers.ModelSerializer):
    recipe = RecipeListSerializer(read_only=True)
    folder = RecipeFolderSerializer(read_only=True)

    class Meta:
        model = SavedRecipe
        fields = ['id', 'recipe', 'folder', 'notes', 'created_at']
        read_only_fields = ['id', 'created_at']


class MealPlanSerializer(serializers.ModelSerializer):
    recipe = RecipeListSerializer(read_only=True)
    recipe_id = serializers.PrimaryKeyRelatedField(
        queryset=Recipe.objects.all(),
        source='recipe',
        write_only=True
    )

    class Meta:
        model = MealPlan
        fields = ['id', 'recipe', 'recipe_id', 'date', 'meal_type', 'servings', 'notes', 'is_cooked', 'created_at']
        read_only_fields = ['id', 'created_at']


class ShoppingListItemSerializer(serializers.ModelSerializer):
    ingredient = IngredientSerializer(read_only=True)
    ingredient_id = serializers.PrimaryKeyRelatedField(
        queryset=Ingredient.objects.all(),
        source='ingredient',
        write_only=True
    )

    class Meta:
        model = ShoppingListItem
        fields = ['id', 'ingredient', 'ingredient_id', 'quantity', 'unit', 'is_purchased', 'notes']


class ShoppingListSerializer(serializers.ModelSerializer):
    items = ShoppingListItemSerializer(many=True, read_only=True)
    items_count = serializers.SerializerMethodField()
    purchased_count = serializers.SerializerMethodField()

    class Meta:
        model = ShoppingList
        fields = ['id', 'name', 'items', 'items_count', 'purchased_count', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_items_count(self, obj):
        return obj.items.count()

    def get_purchased_count(self, obj):
        return obj.items.filter(is_purchased=True).count()
