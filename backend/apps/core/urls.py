from django.urls import path

from apps.core.views import (
    health_check,
    signup,
    get_profile,
    update_profile,
    upload_profile_photo,
)

app_name = "core"

urlpatterns = [
    path("health/", health_check, name="health-check"),
    path("signup/", signup, name="signup"),
    path("profile/", get_profile, name="get-profile"),
    path("profile/", update_profile, name="update-profile"),
    path("profile/photo/", upload_profile_photo, name="upload-profile-photo"),
]
