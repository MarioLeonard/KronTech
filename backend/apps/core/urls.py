from django.urls import path

from apps.core.views import health_check, profile

app_name = "core"

urlpatterns = [
    path("health/", health_check, name="health-check"),
    path("profile/", profile, name="profile"),
]
