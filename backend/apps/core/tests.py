from django.test import TestCase
from django.urls import reverse
import json
from unittest.mock import patch, MagicMock


class HealthCheckTests(TestCase):
    def test_health_check_returns_ok(self):
        response = self.client.get(reverse("core:health-check"))

        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(response.content, {"status": "ok"})


class ProfileSignupTests(TestCase):
    """Test user signup and profile creation."""

    def setUp(self):
        """Set up test client and mock data."""
        self.client = self.client
        self.mock_auth_user = {
            "uid": "test-user-123",
            "email": "testuser@example.com",
            "email_verified": True,
            "display_name": "Test User",
            "photo_url": "https://example.com/photo.jpg",
            "custom_claims": {},
        }

    @patch("apps.core.models.FirestoreService")
    def test_user_profile_model_creation(self, mock_firestore):
        """Test UserProfile model can be created."""
        from apps.core.models import UserProfile
        
        profile_data = {
            "uid": "test-user-123",
            "email": "testuser@example.com",
            "display_name": "Test User",
            "photo_url": "https://example.com/photo.jpg",
        }
        
        profile = UserProfile("test-user-123", profile_data)
        
        # Verify profile properties
        self.assertEqual(profile.uid, "test-user-123")
        self.assertEqual(profile.email, "testuser@example.com")
        self.assertEqual(profile.display_name, "Test User")
        self.assertEqual(profile.photo_url, "https://example.com/photo.jpg")

    @patch("apps.core.models.FirestoreService")
    def test_profile_to_dict(self, mock_firestore):
        """Test converting profile to dictionary."""
        from apps.core.models import UserProfile
        
        profile = UserProfile("test-user-123", {
            "uid": "test-user-123",
            "email": "test@example.com",
            "display_name": "Test",
        })
        
        profile_dict = profile.to_dict()
        
        self.assertIn("uid", profile_dict)
        self.assertIn("email", profile_dict)
        self.assertEqual(profile_dict["uid"], "test-user-123")

    @patch("apps.core.models.FirestoreService")
    def test_profile_from_firebase_user(self, mock_firestore):
        """Test creating profile from Firebase auth data."""
        from apps.core.models import UserProfile
        
        auth_user = {
            "uid": "test-user-123",
            "email": "test@example.com",
            "display_name": "Test User",
            "photo_url": "https://example.com/photo.jpg",
            "email_verified": True,
        }
        
        profile = UserProfile.from_firebase_user("test-user-123", auth_user)
        
        self.assertEqual(profile.uid, "test-user-123")
        self.assertEqual(profile.email, "test@example.com")
        self.assertEqual(profile.display_name, "Test User")

    @patch("common.services.profile_service.UserProfile.get_by_uid")
    @patch("common.services.profile_service.UserProfile.save")
    def test_profile_service_get_or_create(self, mock_save, mock_get_by_uid):
        """Test ProfileService.get_or_create_profile."""
        from common.services.profile_service import ProfileService
        
        mock_get_by_uid.return_value = None  # Profile doesn't exist
        
        auth_user = {
            "uid": "test-user-123",
            "email": "testuser@example.com",
            "display_name": "Test User",
        }
        
        profile = ProfileService.get_or_create_profile(auth_user)
        
        self.assertIsNotNone(profile)
        self.assertEqual(profile.uid, "test-user-123")
        mock_save.assert_called_once()

    @patch("apps.core.models.FirestoreService")
    def test_firestore_collection_name(self, mock_firestore):
        """Test Firestore users collection is properly defined."""
        from apps.core.models import UserProfile
        
        self.assertEqual(UserProfile.COLLECTION, "users")


class SignupEndpointTests(TestCase):
    """Test signup endpoint that creates users in Firestore."""

    def test_profile_endpoint_exists(self):
        """Test that profile endpoint exists and requires auth."""
        response = self.client.get(reverse("core:profile"))
        # Should return 401 because no auth token
        self.assertEqual(response.status_code, 401)

    def test_signup_endpoint_exists(self):
        """Test that signup endpoint exists and requires auth."""
        response = self.client.post(reverse("core:signup"))
        # Should return 401 because no auth token (Firebase validation active)
        self.assertEqual(response.status_code, 401)

    def test_signup_requires_post_method(self):
        """Test that signup only accepts POST requests."""
        response = self.client.get(reverse("core:signup"))
        # GET should fail with 401 (no auth) or 405 (method not allowed)
        self.assertIn(response.status_code, [401, 405])




class FirestoreDatabaseTests(TestCase):
    """Test Firestore database service."""

    @patch("firebase_admin.firestore.client")
    def test_firestore_service_initialization(self, mock_firestore_client):
        """Test FirestoreService initializes correctly."""
        from common.firebase.database import FirestoreService
        
        # Create instance
        service = FirestoreService()
        
        self.assertIsNotNone(service)
