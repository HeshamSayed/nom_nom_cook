"""
Subscription and payment models for Cookpad Egypt
"""
from django.db import models
from django.utils.translation import gettext_lazy as _
from apps.users.models import User


class SubscriptionPlan(models.Model):
    """
    Subscription plan tiers
    """
    PLAN_TYPES = [
        ('individual', 'Individual'),
        ('family', 'Family'),
    ]

    BILLING_PERIODS = [
        ('monthly', 'Monthly'),
        ('quarterly', 'Quarterly'),
        ('yearly', 'Yearly'),
    ]

    name = models.CharField(_('name'), max_length=100)
    name_ar = models.CharField(_('name in Arabic'), max_length=100)
    description = models.TextField(_('description'))
    description_ar = models.TextField(_('description in Arabic'), blank=True)
    plan_type = models.CharField(_('plan type'), max_length=20, choices=PLAN_TYPES)
    billing_period = models.CharField(_('billing period'), max_length=20, choices=BILLING_PERIODS)

    # Pricing
    price_egp = models.DecimalField(_('price (EGP)'), max_digits=10, decimal_places=2)
    price_usd = models.DecimalField(_('price (USD)'), max_digits=10, decimal_places=2, null=True, blank=True)

    # Features
    max_saved_recipes = models.PositiveIntegerField(_('max saved recipes'), default=3000)
    max_family_members = models.PositiveIntegerField(_('max family members'), default=1)
    has_advanced_search = models.BooleanField(_('advanced search'), default=True)
    has_nutritional_info = models.BooleanField(_('nutritional info'), default=True)
    has_popular_recipes = models.BooleanField(_('popular recipes priority'), default=True)
    has_exclusive_content = models.BooleanField(_('exclusive content'), default=True)
    has_offline_access = models.BooleanField(_('offline access'), default=True)
    is_ad_free = models.BooleanField(_('ad-free'), default=True)

    # Stripe integration
    stripe_price_id = models.CharField(_('Stripe price ID'), max_length=255, blank=True)

    is_active = models.BooleanField(_('is active'), default=True)
    order = models.PositiveIntegerField(_('order'), default=0)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('subscription plan')
        verbose_name_plural = _('subscription plans')
        ordering = ['order', 'price_egp']

    def __str__(self):
        return f"{self.name} - {self.billing_period}"


class Subscription(models.Model):
    """
    User subscriptions
    """
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('cancelled', 'Cancelled'),
        ('expired', 'Expired'),
        ('past_due', 'Past Due'),
        ('trialing', 'Trialing'),
    ]

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='subscriptions'
    )
    plan = models.ForeignKey(
        SubscriptionPlan,
        on_delete=models.PROTECT,
        related_name='subscriptions'
    )
    status = models.CharField(_('status'), max_length=20, choices=STATUS_CHOICES)

    # Stripe integration
    stripe_subscription_id = models.CharField(_('Stripe subscription ID'), max_length=255, blank=True)
    stripe_customer_id = models.CharField(_('Stripe customer ID'), max_length=255, blank=True)

    # Dates
    start_date = models.DateTimeField(_('start date'))
    end_date = models.DateTimeField(_('end date'))
    trial_end_date = models.DateTimeField(_('trial end date'), null=True, blank=True)
    cancelled_at = models.DateTimeField(_('cancelled at'), null=True, blank=True)

    auto_renew = models.BooleanField(_('auto renew'), default=True)
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('subscription')
        verbose_name_plural = _('subscriptions')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.plan.name} ({self.status})"


class Payment(models.Model):
    """
    Payment transactions
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('succeeded', 'Succeeded'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded'),
    ]

    subscription = models.ForeignKey(
        Subscription,
        on_delete=models.CASCADE,
        related_name='payments'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='payments'
    )

    amount = models.DecimalField(_('amount'), max_digits=10, decimal_places=2)
    currency = models.CharField(_('currency'), max_length=3, default='EGP')
    status = models.CharField(_('status'), max_length=20, choices=STATUS_CHOICES)

    # Payment provider details
    stripe_payment_intent_id = models.CharField(_('Stripe payment intent ID'), max_length=255, blank=True)
    payment_method = models.CharField(_('payment method'), max_length=50, blank=True)

    # Transaction details
    transaction_id = models.CharField(_('transaction ID'), max_length=255, unique=True)
    failure_reason = models.TextField(_('failure reason'), blank=True)

    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('payment')
        verbose_name_plural = _('payments')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.amount} {self.currency} ({self.status})"


class Coupon(models.Model):
    """
    Discount coupons for premium subscriptions
    """
    DISCOUNT_TYPES = [
        ('percentage', 'Percentage'),
        ('fixed', 'Fixed Amount'),
    ]

    code = models.CharField(_('code'), max_length=50, unique=True)
    description = models.TextField(_('description'))
    discount_type = models.CharField(_('discount type'), max_length=20, choices=DISCOUNT_TYPES)
    discount_value = models.DecimalField(_('discount value'), max_digits=10, decimal_places=2)

    # Restrictions
    min_purchase_amount = models.DecimalField(
        _('minimum purchase amount'),
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True
    )
    max_uses = models.PositiveIntegerField(_('max uses'), null=True, blank=True)
    uses_count = models.PositiveIntegerField(_('uses count'), default=0)

    # Validity
    valid_from = models.DateTimeField(_('valid from'))
    valid_until = models.DateTimeField(_('valid until'))
    is_active = models.BooleanField(_('is active'), default=True)

    # Applicable plans (empty means all plans)
    applicable_plans = models.ManyToManyField(
        SubscriptionPlan,
        blank=True,
        related_name='coupons'
    )

    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        verbose_name = _('coupon')
        verbose_name_plural = _('coupons')
        ordering = ['-created_at']

    def __str__(self):
        return self.code


class CouponUsage(models.Model):
    """
    Track coupon usage by users
    """
    coupon = models.ForeignKey(
        Coupon,
        on_delete=models.CASCADE,
        related_name='usages'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='coupon_usages'
    )
    subscription = models.ForeignKey(
        Subscription,
        on_delete=models.CASCADE,
        related_name='coupon_usages'
    )
    discount_amount = models.DecimalField(_('discount amount'), max_digits=10, decimal_places=2)
    used_at = models.DateTimeField(_('used at'), auto_now_add=True)

    class Meta:
        verbose_name = _('coupon usage')
        verbose_name_plural = _('coupon usages')
        ordering = ['-used_at']

    def __str__(self):
        return f"{self.user.email} used {self.coupon.code}"
