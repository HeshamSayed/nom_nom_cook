from django.contrib import admin
from .models import SubscriptionPlan, Subscription, Payment, Coupon, CouponUsage


@admin.register(SubscriptionPlan)
class SubscriptionPlanAdmin(admin.ModelAdmin):
    list_display = ('name', 'plan_type', 'billing_period', 'price_egp', 'is_active', 'order')
    list_filter = ('plan_type', 'billing_period', 'is_active')
    search_fields = ('name', 'name_ar')


@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = ('user', 'plan', 'status', 'start_date', 'end_date', 'auto_renew')
    list_filter = ('status', 'auto_renew', 'start_date')
    search_fields = ('user__email', 'stripe_subscription_id', 'stripe_customer_id')


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ('user', 'amount', 'currency', 'status', 'payment_method', 'created_at')
    list_filter = ('status', 'currency', 'created_at')
    search_fields = ('user__email', 'transaction_id', 'stripe_payment_intent_id')


@admin.register(Coupon)
class CouponAdmin(admin.ModelAdmin):
    list_display = ('code', 'discount_type', 'discount_value', 'uses_count', 'max_uses', 'valid_from', 'valid_until', 'is_active')
    list_filter = ('discount_type', 'is_active', 'valid_from', 'valid_until')
    search_fields = ('code', 'description')


@admin.register(CouponUsage)
class CouponUsageAdmin(admin.ModelAdmin):
    list_display = ('user', 'coupon', 'discount_amount', 'used_at')
    list_filter = ('used_at',)
    search_fields = ('user__email', 'coupon__code')
