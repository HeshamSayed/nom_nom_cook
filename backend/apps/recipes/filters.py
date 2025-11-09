"""
Filters for the recipes app
"""
import django_filters
from .models import Recipe


class RecipeFilter(django_filters.FilterSet):
    category = django_filters.NumberFilter(field_name='category__id')
    difficulty = django_filters.ChoiceFilter(choices=Recipe.DIFFICULTY_CHOICES)
    prep_time_max = django_filters.NumberFilter(field_name='prep_time', lookup_expr='lte')
    cook_time_max = django_filters.NumberFilter(field_name='cook_time', lookup_expr='lte')
    total_time_max = django_filters.NumberFilter(method='filter_total_time')
    servings_min = django_filters.NumberFilter(field_name='servings', lookup_expr='gte')
    servings_max = django_filters.NumberFilter(field_name='servings', lookup_expr='lte')
    is_vegan = django_filters.BooleanFilter()
    is_vegetarian = django_filters.BooleanFilter()
    is_gluten_free = django_filters.BooleanFilter()
    is_dairy_free = django_filters.BooleanFilter()
    is_keto = django_filters.BooleanFilter()
    is_halal = django_filters.BooleanFilter()
    min_rating = django_filters.NumberFilter(field_name='rating_average', lookup_expr='gte')
    ingredient = django_filters.CharFilter(method='filter_by_ingredient')
    exclude_ingredient = django_filters.CharFilter(method='filter_exclude_ingredient')

    class Meta:
        model = Recipe
        fields = [
            'category', 'difficulty', 'is_vegan', 'is_vegetarian',
            'is_gluten_free', 'is_dairy_free', 'is_keto', 'is_halal'
        ]

    def filter_total_time(self, queryset, name, value):
        """Filter by total time (prep + cook)"""
        from django.db.models import F
        return queryset.filter(prep_time__lte=value - F('cook_time'))

    def filter_by_ingredient(self, queryset, name, value):
        """Filter recipes that contain a specific ingredient"""
        return queryset.filter(
            recipe_ingredients__ingredient__name__icontains=value
        ).distinct()

    def filter_exclude_ingredient(self, queryset, name, value):
        """Exclude recipes that contain a specific ingredient"""
        return queryset.exclude(
            recipe_ingredients__ingredient__name__icontains=value
        ).distinct()
