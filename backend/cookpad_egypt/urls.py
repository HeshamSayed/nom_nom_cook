"""
URL configuration for Cookpad Egypt project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('admin/', admin.site.urls),

    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # API endpoints
    path('api/v1/auth/', include('apps.users.urls')),
    path('api/v1/recipes/', include('apps.recipes.urls')),
    path('api/v1/social/', include('apps.social.urls')),
    path('api/v1/subscriptions/', include('apps.subscriptions.urls')),
    path('api/v1/chat/', include('apps.chat.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

# Admin site customization
admin.site.site_header = "Cookpad Egypt Administration"
admin.site.site_title = "Cookpad Egypt Admin"
admin.site.index_title = "Welcome to Cookpad Egypt Administration"
