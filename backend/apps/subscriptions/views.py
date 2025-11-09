"""
Views for the subscriptions app
"""
from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta
from .models import SubscriptionPlan, Subscription, Payment, Coupon
from .serializers import (
    SubscriptionPlanSerializer, SubscriptionSerializer,
    PaymentSerializer, CouponSerializer, CouponValidationSerializer
)


class SubscriptionPlanViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = SubscriptionPlan.objects.filter(is_active=True)
    serializer_class = SubscriptionPlanSerializer
    permission_classes = [permissions.AllowAny]


class SubscriptionViewSet(viewsets.ModelViewSet):
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Subscription.objects.filter(user=self.request.user)

    @action(detail=False, methods=['get'])
    def current(self, request):
        """Get current active subscription"""
        subscription = self.get_queryset().filter(
            status='active',
            end_date__gte=timezone.now()
        ).first()

        if subscription:
            serializer = self.get_serializer(subscription)
            return Response(serializer.data)

        return Response(
            {'message': 'No active subscription'},
            status=status.HTTP_404_NOT_FOUND
        )

    @action(detail=False, methods=['post'])
    def subscribe(self, request):
        """Create a new subscription"""
        plan_id = request.data.get('plan_id')
        coupon_code = request.data.get('coupon_code')

        try:
            plan = SubscriptionPlan.objects.get(id=plan_id, is_active=True)
        except SubscriptionPlan.DoesNotExist:
            return Response(
                {'error': 'Invalid subscription plan'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check if user already has an active subscription
        active_subscription = self.get_queryset().filter(
            status='active',
            end_date__gte=timezone.now()
        ).first()

        if active_subscription:
            return Response(
                {'error': 'You already have an active subscription'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Calculate subscription dates
        start_date = timezone.now()
        if plan.billing_period == 'monthly':
            end_date = start_date + timedelta(days=30)
        elif plan.billing_period == 'quarterly':
            end_date = start_date + timedelta(days=90)
        else:  # yearly
            end_date = start_date + timedelta(days=365)

        # Create subscription
        subscription = Subscription.objects.create(
            user=request.user,
            plan=plan,
            status='active',
            start_date=start_date,
            end_date=end_date
        )

        # Apply coupon if provided
        discount_amount = 0
        if coupon_code:
            try:
                coupon = Coupon.objects.get(
                    code=coupon_code,
                    is_active=True,
                    valid_from__lte=timezone.now(),
                    valid_until__gte=timezone.now()
                )

                # Check if coupon applies to this plan
                if coupon.applicable_plans.exists() and plan not in coupon.applicable_plans.all():
                    subscription.delete()
                    return Response(
                        {'error': 'Coupon not applicable to this plan'},
                        status=status.HTTP_400_BAD_REQUEST
                    )

                # Calculate discount
                if coupon.discount_type == 'percentage':
                    discount_amount = (plan.price_egp * coupon.discount_value) / 100
                else:
                    discount_amount = coupon.discount_value

                # Create coupon usage
                from .models import CouponUsage
                CouponUsage.objects.create(
                    coupon=coupon,
                    user=request.user,
                    subscription=subscription,
                    discount_amount=discount_amount
                )

                coupon.uses_count += 1
                coupon.save()

            except Coupon.DoesNotExist:
                pass  # Continue without discount

        # Calculate final amount
        final_amount = max(0, float(plan.price_egp) - float(discount_amount))

        # Create payment record
        import uuid
        payment = Payment.objects.create(
            subscription=subscription,
            user=request.user,
            amount=final_amount,
            currency='EGP',
            status='succeeded',  # In production, integrate with Stripe
            transaction_id=str(uuid.uuid4())
        )

        # Update user premium status
        request.user.is_premium = True
        request.user.premium_since = timezone.now()
        request.user.save()

        return Response({
            'subscription': SubscriptionSerializer(subscription).data,
            'payment': PaymentSerializer(payment).data
        }, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Cancel a subscription"""
        subscription = self.get_object()

        if subscription.status != 'active':
            return Response(
                {'error': 'Subscription is not active'},
                status=status.HTTP_400_BAD_REQUEST
            )

        subscription.status = 'cancelled'
        subscription.cancelled_at = timezone.now()
        subscription.auto_renew = False
        subscription.save()

        return Response({'message': 'Subscription cancelled successfully'})


class PaymentViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Payment.objects.filter(user=self.request.user)


class CouponViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Coupon.objects.filter(is_active=True)
    serializer_class = CouponSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'])
    def validate(self, request):
        """Validate a coupon code"""
        serializer = CouponValidationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        code = serializer.validated_data['code']
        plan_id = serializer.validated_data['plan_id']

        try:
            coupon = Coupon.objects.get(
                code=code,
                is_active=True,
                valid_from__lte=timezone.now(),
                valid_until__gte=timezone.now()
            )

            # Check if coupon has uses left
            if coupon.max_uses and coupon.uses_count >= coupon.max_uses:
                return Response(
                    {'error': 'Coupon has reached maximum uses'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Check if coupon applies to the plan
            if coupon.applicable_plans.exists():
                plan = SubscriptionPlan.objects.get(id=plan_id)
                if plan not in coupon.applicable_plans.all():
                    return Response(
                        {'error': 'Coupon not applicable to this plan'},
                        status=status.HTTP_400_BAD_REQUEST
                    )

            return Response({
                'valid': True,
                'coupon': CouponSerializer(coupon).data
            })

        except Coupon.DoesNotExist:
            return Response(
                {'error': 'Invalid coupon code'},
                status=status.HTTP_400_BAD_REQUEST
            )
