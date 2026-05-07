from django.urls import path

from apps.core.views import complete_onboarding, health_check, signup, profile

app_name = "core"

urlpatterns = [
    path("health/", health_check, name="health-check"),
    path("signup/", signup, name="signup"),
    path("profile/", profile, name="profile"),
    path(
        "onboarding/complete/",
        complete_onboarding,
        name="complete-onboarding",
    ),
]
