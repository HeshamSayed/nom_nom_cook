"""
URLs for the recipes app
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CategoryViewSet, IngredientViewSet, RecipeViewSet,
    RecipeFolderViewSet, SavedRecipeViewSet, CookSnapViewSet,
    MealPlanViewSet, ShoppingListViewSet
)

router = DefaultRouter()
router.register(r'categories', CategoryViewSet)
router.register(r'ingredients', IngredientViewSet)
router.register(r'recipes', RecipeViewSet)
router.register(r'folders', RecipeFolderViewSet, basename='folder')
router.register(r'saved', SavedRecipeViewSet, basename='saved')
router.register(r'cooksnaps', CookSnapViewSet, basename='cooksnap')
router.register(r'meal-plans', MealPlanViewSet, basename='mealplan')
router.register(r'shopping-lists', ShoppingListViewSet, basename='shoppinglist')

urlpatterns = [
    path('', include(router.urls)),
]
