"""
Recipe models for Cookpad Egypt
"""
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.core.validators import MinValueValidator, MaxValueValidator
from apps.users.models import User


class Category(models.Model):
    """
    Recipe categories (Egyptian, Italian, Desserts, etc.)
    """
    name = models.CharField(_('name'), max_length=100)
    name_ar = models.CharField(_('name in Arabic'), max_length=100)
    slug = models.SlugField(_('slug'), unique=True)
    description = models.TextField(_('description'), blank=True)
    icon = models.ImageField(_('icon'), upload_to='category_icons/', blank=True, null=True)
    order = models.PositiveIntegerField(_('order'), default=0)
    is_active = models.BooleanField(_('is active'), default=True)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('category')
        verbose_name_plural = _('categories')
        ordering = ['order', 'name']

    def __str__(self):
        return self.name


class Ingredient(models.Model):
    """
    Ingredient database for autocomplete and search
    """
    name = models.CharField(_('name'), max_length=100)
    name_ar = models.CharField(_('name in Arabic'), max_length=100)
    is_common = models.BooleanField(_('is common'), default=False, help_text=_('Common Egyptian ingredients'))
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('ingredient')
        verbose_name_plural = _('ingredients')
        ordering = ['name']

    def __str__(self):
        return self.name


class Recipe(models.Model):
    """
    Main Recipe model
    """
    DIFFICULTY_CHOICES = [
        ('easy', 'Easy'),
        ('medium', 'Medium'),
        ('hard', 'Hard'),
    ]

    VISIBILITY_CHOICES = [
        ('public', 'Public'),
        ('private', 'Private'),
        ('followers', 'Followers Only'),
    ]

    # Basic Information
    title = models.CharField(_('title'), max_length=200)
    title_ar = models.CharField(_('title in Arabic'), max_length=200, blank=True)
    description = models.TextField(_('description'))
    description_ar = models.TextField(_('description in Arabic'), blank=True)

    # Author
    author = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='recipes'
    )

    # Categorization
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        related_name='recipes'
    )
    tags = models.JSONField(_('tags'), default=list, help_text=_('List of tags'))

    # Recipe Details
    prep_time = models.PositiveIntegerField(_('preparation time (minutes)'))
    cook_time = models.PositiveIntegerField(_('cooking time (minutes)'))
    servings = models.PositiveIntegerField(_('servings'))
    difficulty = models.CharField(_('difficulty'), max_length=10, choices=DIFFICULTY_CHOICES)

    # Dietary Information
    is_vegan = models.BooleanField(_('vegan'), default=False)
    is_vegetarian = models.BooleanField(_('vegetarian'), default=False)
    is_gluten_free = models.BooleanField(_('gluten free'), default=False)
    is_dairy_free = models.BooleanField(_('dairy free'), default=False)
    is_keto = models.BooleanField(_('keto'), default=False)
    is_halal = models.BooleanField(_('halal'), default=True)

    # Nutritional Information (optional)
    calories = models.PositiveIntegerField(_('calories'), null=True, blank=True)
    protein = models.DecimalField(_('protein (g)'), max_digits=6, decimal_places=2, null=True, blank=True)
    carbs = models.DecimalField(_('carbohydrates (g)'), max_digits=6, decimal_places=2, null=True, blank=True)
    fat = models.DecimalField(_('fat (g)'), max_digits=6, decimal_places=2, null=True, blank=True)

    # Media
    main_image = models.ImageField(_('main image'), upload_to='recipes/')

    # Engagement Stats
    views_count = models.PositiveIntegerField(_('views count'), default=0)
    likes_count = models.PositiveIntegerField(_('likes count'), default=0)
    saves_count = models.PositiveIntegerField(_('saves count'), default=0)
    cooksnaps_count = models.PositiveIntegerField(_('cooksnaps count'), default=0)
    rating_average = models.DecimalField(
        _('average rating'),
        max_digits=3,
        decimal_places=2,
        default=0.0
    )
    rating_count = models.PositiveIntegerField(_('rating count'), default=0)

    # Visibility
    visibility = models.CharField(
        _('visibility'),
        max_length=10,
        choices=VISIBILITY_CHOICES,
        default='public'
    )
    is_featured = models.BooleanField(_('featured'), default=False)
    is_premium_only = models.BooleanField(_('premium only'), default=False)

    # Timestamps
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)
    published_at = models.DateTimeField(_('published at'), null=True, blank=True)

    class Meta:
        verbose_name = _('recipe')
        verbose_name_plural = _('recipes')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['-created_at']),
            models.Index(fields=['-rating_average']),
            models.Index(fields=['category']),
        ]

    def __str__(self):
        return self.title

    @property
    def total_time(self):
        return self.prep_time + self.cook_time


class RecipeIngredient(models.Model):
    """
    Ingredients for a specific recipe with quantities
    """
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='recipe_ingredients'
    )
    ingredient = models.ForeignKey(
        Ingredient,
        on_delete=models.CASCADE,
        related_name='recipe_uses'
    )
    quantity = models.CharField(_('quantity'), max_length=50)
    unit = models.CharField(_('unit'), max_length=50, blank=True)
    notes = models.CharField(_('notes'), max_length=200, blank=True)
    order = models.PositiveIntegerField(_('order'), default=0)

    class Meta:
        verbose_name = _('recipe ingredient')
        verbose_name_plural = _('recipe ingredients')
        ordering = ['order']

    def __str__(self):
        return f"{self.quantity} {self.unit} {self.ingredient.name}"


class RecipeStep(models.Model):
    """
    Cooking steps for a recipe
    """
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='steps'
    )
    step_number = models.PositiveIntegerField(_('step number'))
    instruction = models.TextField(_('instruction'))
    instruction_ar = models.TextField(_('instruction in Arabic'), blank=True)
    image = models.ImageField(_('image'), upload_to='recipe_steps/', blank=True, null=True)
    duration = models.PositiveIntegerField(_('duration (minutes)'), null=True, blank=True)

    class Meta:
        verbose_name = _('recipe step')
        verbose_name_plural = _('recipe steps')
        ordering = ['step_number']
        unique_together = ('recipe', 'step_number')

    def __str__(self):
        return f"Step {self.step_number} of {self.recipe.title}"


class RecipeImage(models.Model):
    """
    Additional images for a recipe
    """
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='images'
    )
    image = models.ImageField(_('image'), upload_to='recipe_images/')
    caption = models.CharField(_('caption'), max_length=200, blank=True)
    order = models.PositiveIntegerField(_('order'), default=0)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('recipe image')
        verbose_name_plural = _('recipe images')
        ordering = ['order']

    def __str__(self):
        return f"Image for {self.recipe.title}"


class RecipeRating(models.Model):
    """
    User ratings for recipes
    """
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='ratings'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='recipe_ratings'
    )
    rating = models.PositiveIntegerField(
        _('rating'),
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    review = models.TextField(_('review'), blank=True)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('recipe rating')
        verbose_name_plural = _('recipe ratings')
        unique_together = ('recipe', 'user')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} rated {self.recipe.title}: {self.rating}/5"


class CookSnap(models.Model):
    """
    Photos of cooked recipes shared by users
    """
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='cooksnaps'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='cooksnaps'
    )
    image = models.ImageField(_('image'), upload_to='cooksnaps/')
    caption = models.TextField(_('caption'), blank=True)
    likes_count = models.PositiveIntegerField(_('likes count'), default=0)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('cooksnap')
        verbose_name_plural = _('cooksnaps')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username}'s cooksnap of {self.recipe.title}"


class RecipeFolder(models.Model):
    """
    User-created folders to organize saved recipes
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='recipe_folders'
    )
    name = models.CharField(_('name'), max_length=100)
    description = models.TextField(_('description'), blank=True)
    is_private = models.BooleanField(_('private'), default=False)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('recipe folder')
        verbose_name_plural = _('recipe folders')
        ordering = ['name']

    def __str__(self):
        return f"{self.user.username}'s {self.name}"


class SavedRecipe(models.Model):
    """
    Recipes saved by users to folders
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='saved_recipes'
    )
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='saved_by'
    )
    folder = models.ForeignKey(
        RecipeFolder,
        on_delete=models.CASCADE,
        related_name='recipes',
        null=True,
        blank=True
    )
    notes = models.TextField(_('personal notes'), blank=True)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('saved recipe')
        verbose_name_plural = _('saved recipes')
        unique_together = ('user', 'recipe', 'folder')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} saved {self.recipe.title}"


class MealPlan(models.Model):
    """
    User meal planning (Cookplan feature)
    """
    MEAL_TYPE_CHOICES = [
        ('breakfast', 'Breakfast'),
        ('lunch', 'Lunch'),
        ('dinner', 'Dinner'),
        ('snack', 'Snack'),
        ('suhoor', 'Suhoor'),
        ('iftar', 'Iftar'),
    ]

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='meal_plans'
    )
    recipe = models.ForeignKey(
        Recipe,
        on_delete=models.CASCADE,
        related_name='meal_plans'
    )
    date = models.DateField(_('date'))
    meal_type = models.CharField(_('meal type'), max_length=20, choices=MEAL_TYPE_CHOICES)
    servings = models.PositiveIntegerField(_('servings'), default=1)
    notes = models.TextField(_('notes'), blank=True)
    is_cooked = models.BooleanField(_('is cooked'), default=False)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('meal plan')
        verbose_name_plural = _('meal plans')
        ordering = ['date', 'meal_type']

    def __str__(self):
        return f"{self.user.username} - {self.recipe.title} on {self.date}"


class ShoppingList(models.Model):
    """
    Shopping list generated from meal plans and recipes
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='shopping_lists'
    )
    name = models.CharField(_('name'), max_length=100)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('shopping list')
        verbose_name_plural = _('shopping lists')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username}'s {self.name}"


class ShoppingListItem(models.Model):
    """
    Individual items in a shopping list
    """
    shopping_list = models.ForeignKey(
        ShoppingList,
        on_delete=models.CASCADE,
        related_name='items'
    )
    ingredient = models.ForeignKey(
        Ingredient,
        on_delete=models.CASCADE,
        related_name='shopping_list_items'
    )
    quantity = models.CharField(_('quantity'), max_length=50)
    unit = models.CharField(_('unit'), max_length=50, blank=True)
    is_purchased = models.BooleanField(_('purchased'), default=False)
    notes = models.CharField(_('notes'), max_length=200, blank=True)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)

    class Meta:
        verbose_name = _('shopping list item')
        verbose_name_plural = _('shopping list items')
        ordering = ['is_purchased', 'ingredient__name']

    def __str__(self):
        return f"{self.quantity} {self.unit} {self.ingredient.name}"
