"""
Management command to load initial Egyptian recipe data
Usage: python manage.py load_initial_data
"""
from django.core.management.base import BaseCommand
from apps.recipes.models import Category, Ingredient


class Command(BaseCommand):
    help = 'Load initial Egyptian recipe categories and ingredients'

    def handle(self, *args, **options):
        self.stdout.write('Loading initial data...')

        # Create Categories
        categories = [
            {'name': 'Egyptian Cuisine', 'name_ar': 'المطبخ المصري', 'slug': 'egyptian-cuisine'},
            {'name': 'Koshari', 'name_ar': 'كشري', 'slug': 'koshari'},
            {'name': 'Molokhia', 'name_ar': 'ملوخية', 'slug': 'molokhia'},
            {'name': 'Ful & Ta\'meya', 'name_ar': 'فول و طعمية', 'slug': 'ful-tameya'},
            {'name': 'Mahshi', 'name_ar': 'محشي', 'slug': 'mahshi'},
            {'name': 'Desserts', 'name_ar': 'حلويات', 'slug': 'desserts'},
            {'name': 'Ramadan Specials', 'name_ar': 'رمضانيات', 'slug': 'ramadan'},
            {'name': 'Breakfast', 'name_ar': 'فطور', 'slug': 'breakfast'},
            {'name': 'Main Dishes', 'name_ar': 'أطباق رئيسية', 'slug': 'main-dishes'},
            {'name': 'Appetizers', 'name_ar': 'مقبلات', 'slug': 'appetizers'},
            {'name': 'Soups', 'name_ar': 'شوربة', 'slug': 'soups'},
            {'name': 'Salads', 'name_ar': 'سلطات', 'slug': 'salads'},
        ]

        for idx, cat_data in enumerate(categories, start=1):
            category, created = Category.objects.get_or_create(
                slug=cat_data['slug'],
                defaults={
                    **cat_data,
                    'order': idx,
                    'is_active': True
                }
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created category: {category.name}'))

        # Common Egyptian Ingredients
        ingredients = [
            # Grains & Legumes
            {'name': 'Rice', 'name_ar': 'أرز', 'is_common': True},
            {'name': 'Lentils', 'name_ar': 'عدس', 'is_common': True},
            {'name': 'Chickpeas', 'name_ar': 'حمص', 'is_common': True},
            {'name': 'Fava Beans', 'name_ar': 'فول', 'is_common': True},
            {'name': 'Vermicelli', 'name_ar': 'شعيرية', 'is_common': True},
            {'name': 'Pasta', 'name_ar': 'مكرونة', 'is_common': True},

            # Vegetables
            {'name': 'Tomatoes', 'name_ar': 'طماطم', 'is_common': True},
            {'name': 'Onions', 'name_ar': 'بصل', 'is_common': True},
            {'name': 'Garlic', 'name_ar': 'ثوم', 'is_common': True},
            {'name': 'Molokhia Leaves', 'name_ar': 'ملوخية', 'is_common': True},
            {'name': 'Eggplant', 'name_ar': 'باذنجان', 'is_common': True},
            {'name': 'Zucchini', 'name_ar': 'كوسة', 'is_common': True},
            {'name': 'Bell Peppers', 'name_ar': 'فلفل رومي', 'is_common': True},
            {'name': 'Cabbage', 'name_ar': 'كرنب', 'is_common': True},
            {'name': 'Grape Leaves', 'name_ar': 'ورق عنب', 'is_common': True},
            {'name': 'Parsley', 'name_ar': 'بقدونس', 'is_common': True},
            {'name': 'Cilantro', 'name_ar': 'كزبرة', 'is_common': True},
            {'name': 'Dill', 'name_ar': 'شبت', 'is_common': True},
            {'name': 'Mint', 'name_ar': 'نعناع', 'is_common': True},

            # Proteins
            {'name': 'Chicken', 'name_ar': 'دجاج', 'is_common': True},
            {'name': 'Beef', 'name_ar': 'لحم بقري', 'is_common': True},
            {'name': 'Lamb', 'name_ar': 'لحم ضاني', 'is_common': True},
            {'name': 'Fish', 'name_ar': 'سمك', 'is_common': True},
            {'name': 'Eggs', 'name_ar': 'بيض', 'is_common': True},

            # Dairy
            {'name': 'Milk', 'name_ar': 'لبن', 'is_common': True},
            {'name': 'Yogurt', 'name_ar': 'زبادي', 'is_common': True},
            {'name': 'Butter', 'name_ar': 'زبدة', 'is_common': True},
            {'name': 'Cheese', 'name_ar': 'جبنة', 'is_common': True},
            {'name': 'Cream', 'name_ar': 'قشطة', 'is_common': True},

            # Spices
            {'name': 'Cumin', 'name_ar': 'كمون', 'is_common': True},
            {'name': 'Coriander', 'name_ar': 'كزبرة ناشفة', 'is_common': True},
            {'name': 'Black Pepper', 'name_ar': 'فلفل أسود', 'is_common': True},
            {'name': 'Cinnamon', 'name_ar': 'قرفة', 'is_common': True},
            {'name': 'Cardamom', 'name_ar': 'هيل', 'is_common': True},
            {'name': 'Turmeric', 'name_ar': 'كركم', 'is_common': True},
            {'name': 'Paprika', 'name_ar': 'بابريكا', 'is_common': True},
            {'name': 'Bay Leaves', 'name_ar': 'ورق لورا', 'is_common': True},

            # Condiments
            {'name': 'Olive Oil', 'name_ar': 'زيت زيتون', 'is_common': True},
            {'name': 'Vegetable Oil', 'name_ar': 'زيت نباتي', 'is_common': True},
            {'name': 'Tomato Paste', 'name_ar': 'صلصة طماطم', 'is_common': True},
            {'name': 'Vinegar', 'name_ar': 'خل', 'is_common': True},
            {'name': 'Lemon Juice', 'name_ar': 'عصير ليمون', 'is_common': True},
            {'name': 'Salt', 'name_ar': 'ملح', 'is_common': True},
            {'name': 'Sugar', 'name_ar': 'سكر', 'is_common': True},

            # Baking
            {'name': 'Flour', 'name_ar': 'دقيق', 'is_common': True},
            {'name': 'Semolina', 'name_ar': 'سميد', 'is_common': True},
            {'name': 'Baking Powder', 'name_ar': 'بيكنج باودر', 'is_common': True},
            {'name': 'Yeast', 'name_ar': 'خميرة', 'is_common': True},

            # Nuts & Dried Fruits
            {'name': 'Almonds', 'name_ar': 'لوز', 'is_common': False},
            {'name': 'Pistachios', 'name_ar': 'فستق', 'is_common': False},
            {'name': 'Walnuts', 'name_ar': 'جوز', 'is_common': False},
            {'name': 'Raisins', 'name_ar': 'زبيب', 'is_common': False},
            {'name': 'Dates', 'name_ar': 'تمر', 'is_common': True},

            # Sweets
            {'name': 'Honey', 'name_ar': 'عسل', 'is_common': False},
            {'name': 'Molasses', 'name_ar': 'عسل أسود', 'is_common': True},
            {'name': 'Tahini', 'name_ar': 'طحينة', 'is_common': True},
        ]

        for ing_data in ingredients:
            ingredient, created = Ingredient.objects.get_or_create(
                name=ing_data['name'],
                defaults=ing_data
            )
            if created:
                self.stdout.write(f'Created ingredient: {ingredient.name}')

        self.stdout.write(self.style.SUCCESS('Successfully loaded initial data!'))
        self.stdout.write(f'Total categories: {Category.objects.count()}')
        self.stdout.write(f'Total ingredients: {Ingredient.objects.count()}')
