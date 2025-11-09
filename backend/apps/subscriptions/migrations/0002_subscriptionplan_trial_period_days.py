# Generated migration for trial_period_days field

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('subscriptions', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='subscriptionplan',
            name='trial_period_days',
            field=models.PositiveIntegerField(default=60, help_text='Free trial period in days (default: 60 days / 2 months)', verbose_name='trial period (days)'),
        ),
    ]
