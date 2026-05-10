from django.urls import path

from . import views

app_name = "friends"

urlpatterns = [
    path("", views.FriendListView.as_view(), name="friend-list"),
    path("search/", views.FriendSearchView.as_view(), name="friend-search"),
    path("requests/", views.FriendRequestListCreateView.as_view(), name="friend-requests"),
    path(
        "requests/<str:request_id>/accept/",
        views.FriendRequestAcceptView.as_view(),
        name="friend-request-accept",
    ),
    path(
        "requests/<str:request_id>/decline/",
        views.FriendRequestDeclineView.as_view(),
        name="friend-request-decline",
    ),
]
