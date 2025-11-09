"""
URLs for the subscriptions app
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SubscriptionPlanViewSet, SubscriptionViewSet, PaymentViewSet, CouponViewSet

router = DefaultRouter()
router.register(r'plans', SubscriptionPlanViewSet)
router.register(r'subscriptions', SubscriptionViewSet, basename='subscription')
router.register(r'payments', PaymentViewSet, basename='payment')
router.register(r'coupons', CouponViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
