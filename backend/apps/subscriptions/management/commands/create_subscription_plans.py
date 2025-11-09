"""
Management command to create default subscription plans
"""
from django.core.management.base import BaseCommand
from apps.subscriptions.models import SubscriptionPlan


class Command(BaseCommand):
    help = 'Create default subscription plans with 2-month free trial'

    def handle(self, *args, **kwargs):
        self.stdout.write('Creating subscription plans...')

        # Individual Plan
        individual_plan, created = SubscriptionPlan.objects.get_or_create(
            plan_type='individual',
            billing_period='monthly',
            defaults={
                'name': 'Individual Premium',
                'name_ar': 'الفردي المميز',
                'description': 'Perfect for solo cooking enthusiasts. Get full access to all premium features.',
                'description_ar': 'مثالي لعشاق الطبخ المنفردين. احصل على وصول كامل لجميع الميزات المميزة.',
                'price_egp': 29.00,
                'price_usd': 1.00,
                'max_saved_recipes': 10000,
                'max_family_members': 1,
                'has_advanced_search': True,
                'has_nutritional_info': True,
                'has_popular_recipes': True,
                'has_exclusive_content': True,
                'has_offline_access': True,
                'is_ad_free': True,
                'trial_period_days': 60,  # 2 months free trial
                'is_active': True,
                'order': 1,
            }
        )

        if created:
            self.stdout.write(self.style.SUCCESS(f'✓ Created Individual plan with 2-month free trial'))
        else:
            # Update trial period for existing plan
            individual_plan.trial_period_days = 60
            individual_plan.save()
            self.stdout.write(self.style.SUCCESS(f'✓ Updated Individual plan with 2-month free trial'))

        # Family Plan
        family_plan, created = SubscriptionPlan.objects.get_or_create(
            plan_type='family',
            billing_period='monthly',
            defaults={
                'name': 'Family Premium',
                'name_ar': 'العائلي المميز',
                'description': 'Share premium access with up to 6 family members. Cook together, share recipes, and plan meals as a family.',
                'description_ar': 'شارك الوصول المميز مع ما يصل إلى 6 أفراد من العائلة. اطبخوا معًا، شاركوا الوصفات، وخططوا الوجبات كعائلة.',
                'price_egp': 79.00,
                'price_usd': 2.50,
                'max_saved_recipes': 50000,
                'max_family_members': 6,
                'has_advanced_search': True,
                'has_nutritional_info': True,
                'has_popular_recipes': True,
                'has_exclusive_content': True,
                'has_offline_access': True,
                'is_ad_free': True,
                'trial_period_days': 60,  # 2 months free trial
                'is_active': True,
                'order': 2,
            }
        )

        if created:
            self.stdout.write(self.style.SUCCESS(f'✓ Created Family plan with 2-month free trial'))
        else:
            # Update trial period for existing plan
            family_plan.trial_period_days = 60
            family_plan.save()
            self.stdout.write(self.style.SUCCESS(f'✓ Updated Family plan with 2-month free trial'))

        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS('✓ All subscription plans created/updated successfully!'))
        self.stdout.write('')
        self.stdout.write('Plans:')
        self.stdout.write(f'  - Individual: EGP {individual_plan.price_egp}/month (60-day free trial)')
        self.stdout.write(f'  - Family: EGP {family_plan.price_egp}/month (60-day free trial)')
        self.stdout.write('')
        self.stdout.write('Features:')
        self.stdout.write('  ✓ 2 months FREE trial for new users')
        self.stdout.write('  ✓ No payment required during trial')
        self.stdout.write('  ✓ Cancel anytime')
        self.stdout.write('  ✓ All premium features included')
