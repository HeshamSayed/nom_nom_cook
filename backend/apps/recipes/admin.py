from django.contrib import admin
from .models import (
    Category, Ingredient, Recipe, RecipeIngredient, RecipeStep,
    RecipeImage, RecipeRating, CookSnap, RecipeFolder, SavedRecipe,
    MealPlan, ShoppingList, ShoppingListItem
)


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'name_ar', 'slug', 'order', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('name', 'name_ar')
    prepopulated_fields = {'slug': ('name',)}


@admin.register(Ingredient)
class IngredientAdmin(admin.ModelAdmin):
    list_display = ('name', 'name_ar', 'is_common', 'created_at')
    list_filter = ('is_common',)
    search_fields = ('name', 'name_ar')


class RecipeIngredientInline(admin.TabularInline):
    model = RecipeIngredient
    extra = 1


class RecipeStepInline(admin.TabularInline):
    model = RecipeStep
    extra = 1


class RecipeImageInline(admin.TabularInline):
    model = RecipeImage
    extra = 1


@admin.register(Recipe)
class RecipeAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'category', 'difficulty', 'rating_average', 'views_count', 'likes_count', 'is_featured', 'created_at')
    list_filter = ('difficulty', 'category', 'is_featured', 'is_premium_only', 'visibility', 'is_vegan', 'is_vegetarian')
    search_fields = ('title', 'title_ar', 'description', 'author__email')
    readonly_fields = ('views_count', 'likes_count', 'saves_count', 'cooksnaps_count', 'rating_average', 'rating_count')
    inlines = [RecipeIngredientInline, RecipeStepInline, RecipeImageInline]

    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'title_ar', 'description', 'description_ar', 'author', 'category', 'tags', 'main_image')
        }),
        ('Recipe Details', {
            'fields': ('prep_time', 'cook_time', 'servings', 'difficulty')
        }),
        ('Dietary Information', {
            'fields': ('is_vegan', 'is_vegetarian', 'is_gluten_free', 'is_dairy_free', 'is_keto', 'is_halal')
        }),
        ('Nutritional Information', {
            'fields': ('calories', 'protein', 'carbs', 'fat'),
            'classes': ('collapse',)
        }),
        ('Engagement', {
            'fields': ('views_count', 'likes_count', 'saves_count', 'cooksnaps_count', 'rating_average', 'rating_count')
        }),
        ('Settings', {
            'fields': ('visibility', 'is_featured', 'is_premium_only', 'published_at')
        }),
    )


@admin.register(RecipeRating)
class RecipeRatingAdmin(admin.ModelAdmin):
    list_display = ('recipe', 'user', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('recipe__title', 'user__email')


@admin.register(CookSnap)
class CookSnapAdmin(admin.ModelAdmin):
    list_display = ('recipe', 'user', 'likes_count', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('recipe__title', 'user__email', 'caption')


@admin.register(RecipeFolder)
class RecipeFolderAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'is_private', 'created_at')
    list_filter = ('is_private',)
    search_fields = ('name', 'user__email')


@admin.register(SavedRecipe)
class SavedRecipeAdmin(admin.ModelAdmin):
    list_display = ('user', 'recipe', 'folder', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('user__email', 'recipe__title')


@admin.register(MealPlan)
class MealPlanAdmin(admin.ModelAdmin):
    list_display = ('user', 'recipe', 'date', 'meal_type', 'is_cooked')
    list_filter = ('meal_type', 'is_cooked', 'date')
    search_fields = ('user__email', 'recipe__title')


@admin.register(ShoppingList)
class ShoppingListAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'created_at')
    search_fields = ('name', 'user__email')


@admin.register(ShoppingListItem)
class ShoppingListItemAdmin(admin.ModelAdmin):
    list_display = ('ingredient', 'quantity', 'unit', 'shopping_list', 'is_purchased')
    list_filter = ('is_purchased',)
    search_fields = ('ingredient__name', 'shopping_list__name')
