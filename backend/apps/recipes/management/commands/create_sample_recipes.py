from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.recipes.models import (
    Recipe, RecipeIngredient, RecipeStep, Category, Ingredient
)
import random

User = get_user_model()


class Command(BaseCommand):
    help = 'Create sample Egyptian recipes for testing and demonstration'

    def handle(self, *args, **options):
        self.stdout.write('Creating sample Egyptian recipes...')

        # Get or create a demo user
        demo_user, created = User.objects.get_or_create(
            username='chef_egypt',
            defaults={
                'email': 'chef@cookpad-egypt.com',
                'first_name': 'Chef',
                'last_name': 'Egypt',
                'bio': 'Sharing authentic Egyptian recipes with love',
                'preferred_language': 'ar',
            }
        )
        if created:
            demo_user.set_password('demo1234')
            demo_user.save()
            self.stdout.write(self.style.SUCCESS(f'Created demo user: {demo_user.username}'))

        # Create recipes
        recipes_data = [
            {
                'title': 'Egyptian Koshari',
                'title_ar': 'كشري مصري',
                'description': 'Koshari is Egypt\'s national dish - a delicious mix of rice, lentils, pasta, and chickpeas topped with crispy onions and tangy tomato sauce.',
                'description_ar': 'الكشري هو الطبق الوطني لمصر - مزيج لذيذ من الأرز والعدس والمكرونة والحمص مع البصل المقرمش والصلصة الحارة',
                'category': 'Egyptian Cuisine',
                'prep_time': 20,
                'cook_time': 40,
                'servings': 6,
                'difficulty': 'medium',
                'is_vegetarian': True,
                'is_vegan': True,
                'is_halal': True,
                'ingredients': [
                    {'name': 'Rice', 'quantity': '2', 'unit': 'cups'},
                    {'name': 'Brown Lentils', 'quantity': '1', 'unit': 'cup'},
                    {'name': 'Macaroni', 'quantity': '2', 'unit': 'cups'},
                    {'name': 'Chickpeas', 'quantity': '1', 'unit': 'can'},
                    {'name': 'Onions', 'quantity': '4', 'unit': 'large'},
                    {'name': 'Tomato Sauce', 'quantity': '2', 'unit': 'cups'},
                    {'name': 'Garlic', 'quantity': '4', 'unit': 'cloves'},
                    {'name': 'Cumin', 'quantity': '2', 'unit': 'tsp'},
                    {'name': 'Vegetable Oil', 'quantity': '0.5', 'unit': 'cup'},
                    {'name': 'Salt', 'quantity': '1', 'unit': 'to taste'},
                ],
                'steps': [
                    'Cook rice according to package instructions and set aside.',
                    'Boil lentils in salted water until tender but not mushy, about 20 minutes. Drain and set aside.',
                    'Cook macaroni according to package instructions, drain and set aside.',
                    'Slice onions thinly and fry in vegetable oil until dark golden and crispy. Drain on paper towels.',
                    'In a pot, sauté minced garlic in 2 tablespoons oil until fragrant.',
                    'Add tomato sauce, cumin, salt, and a splash of water. Simmer for 15 minutes.',
                    'To serve, layer rice, lentils, macaroni, and chickpeas in a bowl.',
                    'Top with tomato sauce and crispy fried onions.',
                    'Serve hot with vinegar and hot sauce on the side.',
                ],
                'tags': ['Egyptian', 'Vegetarian', 'Main Course', 'Comfort Food', 'Street Food'],
            },
            {
                'title': 'Traditional Molokhia',
                'title_ar': 'ملوخية تقليدية',
                'description': 'A beloved Egyptian green soup made from molokhia leaves, served with rice or bread. Rich, garlicky, and incredibly flavorful.',
                'description_ar': 'شوربة خضراء مصرية محبوبة من أوراق الملوخية، تقدم مع الأرز أو الخبز. غنية بالثوم ولذيذة جداً',
                'category': 'Egyptian Cuisine',
                'prep_time': 15,
                'cook_time': 30,
                'servings': 4,
                'difficulty': 'easy',
                'is_halal': True,
                'ingredients': [
                    {'name': 'Molokhia Leaves', 'quantity': '500', 'unit': 'grams'},
                    {'name': 'Chicken', 'quantity': '1', 'unit': 'kg'},
                    {'name': 'Garlic', 'quantity': '8', 'unit': 'cloves'},
                    {'name': 'Coriander', 'quantity': '2', 'unit': 'tsp'},
                    {'name': 'Chicken Broth', 'quantity': '6', 'unit': 'cups'},
                    {'name': 'Butter', 'quantity': '3', 'unit': 'tbsp'},
                    {'name': 'Salt', 'quantity': '1', 'unit': 'to taste'},
                    {'name': 'Black Pepper', 'quantity': '1', 'unit': 'to taste'},
                ],
                'steps': [
                    'Boil chicken in water with salt and pepper until cooked through, about 45 minutes.',
                    'Remove chicken and strain broth. Set both aside.',
                    'Finely chop or blend molokhia leaves.',
                    'Bring chicken broth to a boil and add the molokhia leaves.',
                    'Stir continuously and let simmer for 10 minutes.',
                    'In a separate pan, melt butter and sauté minced garlic and coriander until golden.',
                    'Add the garlic mixture to the molokhia and stir well.',
                    'Simmer for another 5 minutes.',
                    'Serve hot over rice with the boiled chicken on the side.',
                    'Garnish with lemon wedges if desired.',
                ],
                'tags': ['Egyptian', 'Soup', 'Comfort Food', 'Traditional', 'Family Meal'],
            },
            {
                'title': 'Ful Medames - Egyptian Fava Beans',
                'title_ar': 'فول مدمس',
                'description': 'The breakfast of champions! Slow-cooked fava beans seasoned with cumin, garlic, and lemon. A staple Egyptian breakfast dish.',
                'description_ar': 'فطور البطل! فول مطبوخ ببطء متبل بالكمون والثوم والليمون. طبق فطور مصري أساسي',
                'category': 'Egyptian Cuisine',
                'prep_time': 10,
                'cook_time': 180,
                'servings': 4,
                'difficulty': 'easy',
                'is_vegetarian': True,
                'is_vegan': True,
                'is_halal': True,
                'ingredients': [
                    {'name': 'Fava Beans', 'quantity': '2', 'unit': 'cups'},
                    {'name': 'Garlic', 'quantity': '4', 'unit': 'cloves'},
                    {'name': 'Lemon', 'quantity': '2', 'unit': 'pieces'},
                    {'name': 'Cumin', 'quantity': '1', 'unit': 'tsp'},
                    {'name': 'Olive Oil', 'quantity': '0.25', 'unit': 'cup'},
                    {'name': 'Salt', 'quantity': '1', 'unit': 'to taste'},
                    {'name': 'Tomatoes', 'quantity': '2', 'unit': 'medium'},
                    {'name': 'Onions', 'quantity': '1', 'unit': 'small'},
                ],
                'steps': [
                    'Soak fava beans overnight in water.',
                    'Drain and place in a large pot with fresh water.',
                    'Bring to a boil, then reduce heat and simmer for 2-3 hours until very tender.',
                    'Drain most of the cooking liquid, leaving beans slightly moist.',
                    'Mash some of the beans with a fork while leaving some whole.',
                    'Add minced garlic, cumin, salt, and lemon juice. Mix well.',
                    'Heat olive oil in a pan and add the ful mixture.',
                    'Cook for 5 minutes, stirring occasionally.',
                    'Serve in bowls topped with diced tomatoes, onions, and a drizzle of olive oil.',
                    'Best enjoyed with Egyptian baladi bread!',
                ],
                'tags': ['Egyptian', 'Breakfast', 'Vegetarian', 'Vegan', 'Healthy', 'Street Food'],
            },
            {
                'title': 'Mahshi - Stuffed Vegetables',
                'title_ar': 'محشي',
                'description': 'A beloved Egyptian dish of vegetables stuffed with a seasoned rice mixture. Includes zucchini, peppers, and vine leaves.',
                'description_ar': 'طبق مصري محبوب من الخضروات المحشوة بخليط أرز متبل. يشمل الكوسة والفلفل وورق العنب',
                'category': 'Egyptian Cuisine',
                'prep_time': 45,
                'cook_time': 60,
                'servings': 6,
                'difficulty': 'hard',
                'is_halal': True,
                'ingredients': [
                    {'name': 'Zucchini', 'quantity': '8', 'unit': 'medium'},
                    {'name': 'Bell Peppers', 'quantity': '6', 'unit': 'pieces'},
                    {'name': 'Vine Leaves', 'quantity': '20', 'unit': 'pieces'},
                    {'name': 'Rice', 'quantity': '2', 'unit': 'cups'},
                    {'name': 'Ground Beef', 'quantity': '500', 'unit': 'grams'},
                    {'name': 'Tomato Paste', 'quantity': '3', 'unit': 'tbsp'},
                    {'name': 'Onions', 'quantity': '2', 'unit': 'medium'},
                    {'name': 'Garlic', 'quantity': '6', 'unit': 'cloves'},
                    {'name': 'Dill', 'quantity': '0.5', 'unit': 'cup'},
                    {'name': 'Parsley', 'quantity': '0.5', 'unit': 'cup'},
                    {'name': 'Salt', 'quantity': '1', 'unit': 'to taste'},
                    {'name': 'Black Pepper', 'quantity': '1', 'unit': 'to taste'},
                ],
                'steps': [
                    'Wash rice and soak for 15 minutes, then drain.',
                    'Mix rice with ground beef, finely chopped onions, dill, parsley, salt, and pepper.',
                    'Core zucchini using a corer, leaving one end closed.',
                    'Cut tops off bell peppers and remove seeds.',
                    'If using fresh vine leaves, blanch in boiling water for 2 minutes.',
                    'Stuff vegetables about 3/4 full with the rice mixture (rice will expand).',
                    'For vine leaves, place a spoonful of filling and roll tightly.',
                    'Arrange stuffed vegetables in a large pot, packed tightly.',
                    'Mix tomato paste with water and minced garlic, pour over vegetables.',
                    'Add water to cover vegetables, place a heavy plate on top to keep them in place.',
                    'Bring to a boil, then simmer on low heat for 1 hour until rice is cooked.',
                    'Serve hot with yogurt on the side.',
                ],
                'tags': ['Egyptian', 'Main Course', 'Traditional', 'Family Meal', 'Special Occasion'],
            },
            {
                'title': 'Basbousa - Egyptian Semolina Cake',
                'title_ar': 'بسبوسة',
                'description': 'A sweet, syrupy semolina cake that\'s a favorite Egyptian dessert. Moist, fragrant with coconut, and soaked in sugar syrup.',
                'description_ar': 'كعكة السميد الحلوة المشبعة بالشيرة، حلوى مصرية مفضلة. رطبة ومعطرة بجوز الهند',
                'category': 'Desserts',
                'prep_time': 15,
                'cook_time': 35,
                'servings': 12,
                'difficulty': 'easy',
                'is_vegetarian': True,
                'is_halal': True,
                'ingredients': [
                    {'name': 'Semolina', 'quantity': '2', 'unit': 'cups'},
                    {'name': 'Coconut', 'quantity': '1', 'unit': 'cup'},
                    {'name': 'Sugar', 'quantity': '0.75', 'unit': 'cup'},
                    {'name': 'Yogurt', 'quantity': '1', 'unit': 'cup'},
                    {'name': 'Butter', 'quantity': '0.75', 'unit': 'cup'},
                    {'name': 'Baking Powder', 'quantity': '1', 'unit': 'tbsp'},
                    {'name': 'Vanilla', 'quantity': '1', 'unit': 'tsp'},
                    {'name': 'Almonds', 'quantity': '24', 'unit': 'pieces'},
                    {'name': 'Water', 'quantity': '1.5', 'unit': 'cups'},
                    {'name': 'Lemon Juice', 'quantity': '1', 'unit': 'tbsp'},
                ],
                'steps': [
                    'Preheat oven to 180°C (350°F).',
                    'In a large bowl, mix semolina, coconut, sugar, and baking powder.',
                    'Melt butter and add to the mixture along with yogurt and vanilla.',
                    'Mix until well combined. The mixture should be thick and spreadable.',
                    'Grease a 9x13 inch baking pan and spread the mixture evenly.',
                    'Let rest for 10 minutes.',
                    'Cut into diamond or square shapes and place an almond on each piece.',
                    'Bake for 30-35 minutes until golden brown.',
                    'While baking, prepare syrup: boil sugar and water for 10 minutes, add lemon juice.',
                    'Remove basbousa from oven and immediately pour cooled syrup over hot cake.',
                    'Let soak for at least 2 hours before serving.',
                    'Serve at room temperature.',
                ],
                'tags': ['Egyptian', 'Dessert', 'Sweet', 'Traditional', 'Special Occasion'],
            },
            {
                'title': 'Ta\'ameya - Egyptian Falafel',
                'title_ar': 'طعمية',
                'description': 'Egyptian-style falafel made with fava beans instead of chickpeas. Crispy outside, fluffy inside, and full of flavor.',
                'description_ar': 'الفلافل المصري المصنوع من الفول بدلاً من الحمص. مقرمش من الخارج، طري من الداخل، ومليء بالنكهة',
                'category': 'Egyptian Cuisine',
                'prep_time': 480,
                'cook_time': 20,
                'servings': 6,
                'difficulty': 'medium',
                'is_vegetarian': True,
                'is_vegan': True,
                'is_halal': True,
                'ingredients': [
                    {'name': 'Fava Beans', 'quantity': '2', 'unit': 'cups'},
                    {'name': 'Onions', 'quantity': '1', 'unit': 'large'},
                    {'name': 'Garlic', 'quantity': '4', 'unit': 'cloves'},
                    {'name': 'Fresh Cilantro', 'quantity': '1', 'unit': 'cup'},
                    {'name': 'Parsley', 'quantity': '1', 'unit': 'cup'},
                    {'name': 'Green Onions', 'quantity': '4', 'unit': 'stalks'},
                    {'name': 'Cumin', 'quantity': '2', 'unit': 'tsp'},
                    {'name': 'Coriander', 'quantity': '2', 'unit': 'tsp'},
                    {'name': 'Baking Powder', 'quantity': '1', 'unit': 'tsp'},
                    {'name': 'Salt', 'quantity': '1', 'unit': 'to taste'},
                    {'name': 'Vegetable Oil', 'quantity': '2', 'unit': 'cups'},
                ],
                'steps': [
                    'Soak dried fava beans overnight (at least 8 hours).',
                    'Drain beans and remove skins if desired.',
                    'In a food processor, grind beans until fine but not paste-like.',
                    'Add onions, garlic, cilantro, parsley, and green onions. Pulse until well mixed.',
                    'Transfer to a bowl and add cumin, coriander, salt, and baking powder.',
                    'Mix well and refrigerate for at least 1 hour.',
                    'Heat oil in a deep pan to 350°F (180°C).',
                    'Shape mixture into small patties or use a falafel scoop.',
                    'Carefully drop into hot oil, fry for 3-4 minutes until golden brown.',
                    'Remove and drain on paper towels.',
                    'Serve hot in pita bread with tahini sauce, tomatoes, and pickles.',
                    'Best enjoyed fresh and hot!',
                ],
                'tags': ['Egyptian', 'Vegetarian', 'Vegan', 'Street Food', 'Breakfast', 'Lunch'],
            },
        ]

        created_count = 0
        for recipe_data in recipes_data:
            # Get or create category
            category, _ = Category.objects.get_or_create(
                slug=recipe_data['category'].lower().replace(' ', '-'),
                defaults={
                    'name': recipe_data['category'],
                    'name_ar': recipe_data.get('category_ar', recipe_data['category']),
                }
            )

            # Check if recipe already exists
            if Recipe.objects.filter(title=recipe_data['title']).exists():
                self.stdout.write(
                    self.style.WARNING(f'Recipe "{recipe_data["title"]}" already exists. Skipping...')
                )
                continue

            # Create recipe
            recipe = Recipe.objects.create(
                author=demo_user,
                title=recipe_data['title'],
                title_ar=recipe_data.get('title_ar', recipe_data['title']),
                description=recipe_data['description'],
                description_ar=recipe_data.get('description_ar', recipe_data['description']),
                category=category,
                prep_time=recipe_data['prep_time'],
                cook_time=recipe_data['cook_time'],
                servings=recipe_data['servings'],
                difficulty=recipe_data['difficulty'],
                is_vegetarian=recipe_data.get('is_vegetarian', False),
                is_vegan=recipe_data.get('is_vegan', False),
                is_gluten_free=recipe_data.get('is_gluten_free', False),
                is_dairy_free=recipe_data.get('is_dairy_free', False),
                is_halal=recipe_data.get('is_halal', False),
                status='published',
                likes_count=random.randint(50, 500),
                saves_count=random.randint(20, 200),
                views_count=random.randint(100, 1000),
            )

            # Add tags
            if 'tags' in recipe_data:
                recipe.tags = ','.join(recipe_data['tags'])
                recipe.save()

            # Create ingredients
            for idx, ingredient_data in enumerate(recipe_data['ingredients'], start=1):
                # Get or create ingredient
                ingredient, _ = Ingredient.objects.get_or_create(
                    name=ingredient_data['name'],
                    defaults={
                        'name_ar': ingredient_data.get('name_ar', ingredient_data['name']),
                        'is_common': True,
                    }
                )

                RecipeIngredient.objects.create(
                    recipe=recipe,
                    ingredient=ingredient,
                    quantity=ingredient_data['quantity'],
                    unit=ingredient_data['unit'],
                    order=idx,
                )

            # Create steps
            for idx, step_text in enumerate(recipe_data['steps'], start=1):
                RecipeStep.objects.create(
                    recipe=recipe,
                    step_number=idx,
                    instruction=step_text,
                )

            created_count += 1
            self.stdout.write(
                self.style.SUCCESS(f'Created recipe: {recipe.title}')
            )

        self.stdout.write(
            self.style.SUCCESS(
                f'\nSuccessfully created {created_count} Egyptian recipes!'
            )
        )
        self.stdout.write(
            'You can now view these recipes in the app or admin panel.'
        )
