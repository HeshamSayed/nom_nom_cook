"""
URLs for the social app
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CommentViewSet, NotificationViewSet, ReportViewSet

router = DefaultRouter()
router.register(r'comments', CommentViewSet, basename='comment')
router.register(r'notifications', NotificationViewSet, basename='notification')
router.register(r'reports', ReportViewSet, basename='report')

urlpatterns = [
    path('', include(router.urls)),
]
