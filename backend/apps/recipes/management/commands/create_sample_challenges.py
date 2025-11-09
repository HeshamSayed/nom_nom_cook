from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from apps.recipes.models import Challenge


class Command(BaseCommand):
    help = 'Create sample challenges for testing'

    def handle(self, *args, **options):
        self.stdout.write('Creating sample challenges...\n')

        now = timezone.now()

        challenges_data = [
            {
                'title': 'Best Egyptian Dessert of the Month',
                'title_ar': 'أفضل حلوى مصرية للشهر',
                'description': 'Show us your best Egyptian dessert! Whether it\'s traditional basbousa, creamy mahalabia, or your grandmother\'s secret kunafa recipe - we want to see it all. The most voted dessert wins!',
                'description_ar': 'أظهر لنا أفضل حلوى مصرية لديك! سواء كانت بسبوسة تقليدية، مهلبية كريمية، أو وصفة الكنافة السرية لجدتك - نريد أن نرى كل شيء. الحلوى الأكثر تصويتًا تفوز!',
                'theme': 'Egyptian Desserts',
                'theme_ar': 'الحلويات المصرية',
                'start_date': now - timedelta(days=5),
                'end_date': now + timedelta(days=20),
                'voting_end_date': now + timedelta(days=25),
                'status': 'active',
                'prize_description': '🏆 Winner receives:\n- Featured on homepage for 1 month\n- Premium subscription for 3 months\n- Special "Master Chef" badge',
                'prize_description_ar': '🏆 الفائز يحصل على:\n- عرض على الصفحة الرئيسية لمدة شهر\n- اشتراك بريميوم لمدة 3 أشهر\n- شارة "ماستر شيف" خاصة',
            },
            {
                'title': 'Quick & Healthy Breakfast Challenge',
                'title_ar': 'تحدي الفطور السريع والصحي',
                'description': 'Create a delicious, healthy breakfast that can be prepared in 15 minutes or less. Perfect for busy mornings! Must include nutritional information.',
                'description_ar': 'أنشئ فطورًا لذيذًا وصحيًا يمكن تحضيره في 15 دقيقة أو أقل. مثالي للصباحات المزدحمة! يجب تضمين المعلومات الغذائية.',
                'theme': 'Healthy Breakfast',
                'theme_ar': 'فطور صحي',
                'start_date': now + timedelta(days=10),
                'end_date': now + timedelta(days=40),
                'voting_end_date': now + timedelta(days=45),
                'status': 'upcoming',
                'prize_description': '🏆 Winner receives:\n- Featured in newsletter\n- Premium subscription for 2 months\n- Certificate of Achievement',
                'prize_description_ar': '🏆 الفائز يحصل على:\n- عرض في النشرة الإخبارية\n- اشتراك بريميوم لمدة شهرين\n- شهادة تقدير',
            },
            {
                'title': 'Ramadan Iftar Special',
                'title_ar': 'إفطار رمضان الخاص',
                'description': 'Share your favorite Ramadan iftar recipe! From soups to main dishes, show us what makes your iftar table special. Traditional or modern twists welcome!',
                'description_ar': 'شارك وصفة إفطار رمضان المفضلة لديك! من الشوربات إلى الأطباق الرئيسية، أظهر لنا ما يجعل مائدة إفطارك مميزة. مرحب بالوصفات التقليدية أو اللمسات العصرية!',
                'theme': 'Ramadan Iftar',
                'theme_ar': 'إفطار رمضان',
                'start_date': now + timedelta(days=30),
                'end_date': now + timedelta(days=60),
                'voting_end_date': now + timedelta(days=65),
                'status': 'upcoming',
                'prize_description': '🏆 Winner receives:\n- Featured during Ramadan\n- Premium subscription for 6 months\n- Cooking utensils gift set\n- "Ramadan Master" badge',
                'prize_description_ar': '🏆 الفائز يحصل على:\n- عرض خلال رمضان\n- اشتراك بريميوم لمدة 6 أشهر\n- طقم أدوات طبخ هدية\n- شارة "ماستر رمضان"',
            },
        ]

        created_count = 0
        for challenge_data in challenges_data:
            # Check if challenge already exists
            if Challenge.objects.filter(title=challenge_data['title']).exists():
                self.stdout.write(
                    self.style.WARNING(
                        f'Challenge "{challenge_data["title"]}" already exists. Skipping...'
                    )
                )
                continue

            challenge = Challenge.objects.create(**challenge_data)
            created_count += 1

            status_emoji = {
                'upcoming': '📅',
                'active': '🔥',
                'voting': '🗳️',
                'completed': '✅'
            }

            self.stdout.write(
                self.style.SUCCESS(
                    f'{status_emoji[challenge.status]} Created: {challenge.title} ({challenge.status.upper()})'
                )
            )

        self.stdout.write(
            self.style.SUCCESS(
                f'\n✅ Successfully created {created_count} challenges!'
            )
        )
        self.stdout.write(
            '\nRun "python manage.py process_challenges" to update challenge statuses'
        )
