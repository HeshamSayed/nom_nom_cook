"""
Serializers for the subscriptions app
"""
from rest_framework import serializers
from .models import SubscriptionPlan, Subscription, Payment, Coupon, CouponUsage


class SubscriptionPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = SubscriptionPlan
        fields = [
            'id', 'name', 'name_ar', 'description', 'description_ar',
            'plan_type', 'billing_period', 'price_egp', 'price_usd',
            'max_saved_recipes', 'max_family_members', 'has_advanced_search',
            'has_nutritional_info', 'has_popular_recipes', 'has_exclusive_content',
            'has_offline_access', 'is_ad_free', 'trial_period_days', 'is_active'
        ]


class SubscriptionSerializer(serializers.ModelSerializer):
    plan = SubscriptionPlanSerializer(read_only=True)
    plan_id = serializers.PrimaryKeyRelatedField(
        queryset=SubscriptionPlan.objects.filter(is_active=True),
        source='plan',
        write_only=True
    )

    class Meta:
        model = Subscription
        fields = [
            'id', 'plan', 'plan_id', 'status', 'start_date', 'end_date',
            'trial_end_date', 'cancelled_at', 'auto_renew', 'created_at'
        ]
        read_only_fields = ['id', 'status', 'created_at']


class PaymentSerializer(serializers.ModelSerializer):
    subscription = SubscriptionSerializer(read_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'subscription', 'amount', 'currency', 'status',
            'payment_method', 'transaction_id', 'failure_reason', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = Coupon
        fields = [
            'id', 'code', 'description', 'discount_type', 'discount_value',
            'min_purchase_amount', 'max_uses', 'uses_count',
            'valid_from', 'valid_until', 'is_active'
        ]
        read_only_fields = ['id', 'uses_count']


class CouponValidationSerializer(serializers.Serializer):
    code = serializers.CharField()
    plan_id = serializers.IntegerField()


class CouponUsageSerializer(serializers.ModelSerializer):
    coupon = CouponSerializer(read_only=True)
    subscription = SubscriptionSerializer(read_only=True)

    class Meta:
        model = CouponUsage
        fields = ['id', 'coupon', 'subscription', 'discount_amount', 'used_at']
        read_only_fields = ['id', 'used_at']
