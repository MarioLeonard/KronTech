from django.urls import path

from apps.core.views import (
    health_check,
    signup,
    profile,
    get_profile,
    update_profile,
    upload_profile_photo,
    trips,
    generate_trip,
    get_trip,
    update_trip,
    delete_trip,
)

app_name = "core"

urlpatterns = [
    path("health/", health_check, name="health-check"),
    path("signup/", signup, name="signup"),
    path("profile/", profile, name="profile"),
    path("profile/", get_profile, name="get-profile"),
    path("profile/", update_profile, name="update-profile"),
    path("profile/photo/", upload_profile_photo, name="upload-profile-photo"),
    # Trip endpoints
    path("trips/generate/", generate_trip, name="generate-trip"),
    path("trips/", trips, name="trips"),
    path("trips/<str:trip_id>/", get_trip, name="get-trip"),
    path("trips/<str:trip_id>/", update_trip, name="update-trip"),
    path("trips/<str:trip_id>/", delete_trip, name="delete-trip"),
]
