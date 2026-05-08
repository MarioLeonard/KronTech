"""
Comprehensive tests for profile endpoints with Firebase authentication.

Tests cover:
- UID validation: User cannot edit another user's profile
- Field whitelist validation: Only allowed fields can be updated
- Photo upload: File is saved to Firebase Storage and URL is saved to Firestore
- Security: All endpoints require valid Firebase token
"""

import json
from unittest.mock import Mock, patch, MagicMock
from io import BytesIO

from django.test import TestCase, RequestFactory
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse

from apps.core.models import UserProfile
from apps.core.views import get_profile, update_profile, upload_profile_photo
from common.authentication import firebase_required
from common.firebase.types import AuthenticatedUser


class HealthCheckTests(TestCase):
    def test_health_check_returns_ok(self):
        response = self.client.get(reverse("core:health-check"))

        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(response.content, {"status": "ok"})


class ProfileEndpointsSecurityTest(TestCase):
    """Tests for security and authorization of profile endpoints."""

    def setUp(self):
        """Set up test fixtures."""
        self.factory = RequestFactory()
        self.uid_alice = "uid_alice_12345"
        self.uid_bob = "uid_bob_67890"
        
        self.auth_user_alice: AuthenticatedUser = {
            "uid": self.uid_alice,
            "email": "alice@example.com",
            "email_verified": True,
            "display_name": "Alice",
            "photo_url": None,
        }
        
        self.auth_user_bob: AuthenticatedUser = {
            "uid": self.uid_bob,
            "email": "bob@example.com",
            "email_verified": True,
            "display_name": "Bob",
            "photo_url": None,
        }

    def _create_request(self, method, path, body=None, auth_user=None):
        """Helper to create a mock request with auth_user and Authorization header."""
        auth_user = auth_user or self.auth_user_alice
        
        if method == "GET":
            request = self.factory.get(
                path,
                HTTP_AUTHORIZATION="Bearer fake-token",
            )
        elif method == "PATCH":
            request = self.factory.patch(
                path,
                data=json.dumps(body) if body else "",
                content_type="application/json",
                HTTP_AUTHORIZATION="Bearer fake-token",
            )
        elif method == "POST":
            request = self.factory.post(
                path,
                HTTP_AUTHORIZATION="Bearer fake-token",
            )
        else:
            raise ValueError(f"Unsupported method: {method}")
        
        request.auth_user = auth_user
        request.auth_user_id = auth_user["uid"]
        return request

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.get_or_create_profile")
    def test_get_profile_returns_own_profile(self, mock_get_profile, mock_verify_token):
        """Test that user can retrieve their own profile."""
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        mock_profile = Mock(spec=UserProfile)
        mock_profile.to_dict.return_value = {
            "uid": self.uid_alice,
            "email": "alice@example.com",
        }
        mock_get_profile.return_value = mock_profile

        request = self._create_request("GET", "/api/profile/")
        response = get_profile(request)

        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertEqual(data["profile"]["uid"], self.uid_alice)

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.update_profile")
    def test_user_cannot_edit_another_uid(self, mock_update, mock_verify_token):
        """
        SECURITY TEST: User cannot edit another user's profile.
        
        This is enforced by always using the UID from the token,
        never from the request body.
        """
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        # Alice tries to update, but includes Bob's UID in the body
        attack_payload = {
            "uid": self.uid_bob,  # Attempt to change uid
            "firstName": "Hacker",
            "lastName": "Attacker",
        }

        mock_profile = Mock(spec=UserProfile)
        mock_profile.to_dict.return_value = {"uid": self.uid_alice}
        mock_update.return_value = mock_profile

        request = self._create_request(
            "PATCH",
            "/api/profile/",
            body=attack_payload,
            auth_user=self.auth_user_alice,
        )
        response = update_profile(request)

        # Verify the update was called with Alice's UID, not Bob's
        self.assertEqual(response.status_code, 200)
        mock_update.assert_called_once()
        call_args = mock_update.call_args
        
        # First argument should be Alice's UID (extracted from token)
        self.assertEqual(call_args[0][0], self.uid_alice)

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.update_profile")
    def test_non_whitelisted_fields_are_ignored(self, mock_update, mock_verify_token):
        """
        SECURITY TEST: Non-whitelisted fields are filtered by ProfileService.
        
        Note: Filtering happens at the service layer, not the view layer.
        The view passes all data to the service, which then filters it.
        """
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        payload = {
            # Allowed fields
            "firstName": "Alice",
            "lastName": "Smith",
            # Non-allowed fields that should be filtered out by the service
            "email": "newemail@example.com",
            "uid": "different_uid",
            "email_verified": True,
            "created_at": "2025-01-01",
            "profilePhotoUrl": "https://malicious.com/photo.jpg",
        }

        mock_profile = Mock(spec=UserProfile)
        mock_profile.to_dict.return_value = {"uid": self.uid_alice}
        mock_update.return_value = mock_profile

        request = self._create_request(
            "PATCH",
            "/api/profile/",
            body=payload,
            auth_user=self.auth_user_alice,
        )
        response = update_profile(request)

        self.assertEqual(response.status_code, 200)
        
        # Verify ProfileService.update_profile was called with all data
        # (filtering happens inside the service)
        mock_update.assert_called_once()
        call_args = mock_update.call_args
        passed_data = call_args[0][1]
        
        # The service receives all data and filters it internally
        self.assertIn("firstName", passed_data)
        self.assertIn("lastName", passed_data)

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.update_profile")
    def test_only_allowed_fields_accepted(self, mock_update, mock_verify_token):
        """Test that only whitelisted fields are accepted and updated."""
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        allowed_payload = {
            "firstName": "John",
            "lastName": "Doe",
            "dateOfBirth": "1990-01-15",
            "gender": "M",
            "country": "Romania",
            "city": "Bucharest",
            "street": "Main St 123",
        }

        mock_profile = Mock(spec=UserProfile)
        mock_profile.to_dict.return_value = {"uid": self.uid_alice}
        mock_update.return_value = mock_profile

        request = self._create_request(
            "PATCH",
            "/api/profile/",
            body=allowed_payload,
            auth_user=self.auth_user_alice,
        )
        response = update_profile(request)

        self.assertEqual(response.status_code, 200)
        
        # Verify all allowed fields were passed
        call_args = mock_update.call_args
        update_data = call_args[0][1]
        
        for field in allowed_payload.keys():
            self.assertIn(field, update_data)
            self.assertEqual(update_data[field], allowed_payload[field])


class ProfilePhotoUploadTest(TestCase):
    """Tests for profile photo upload endpoint."""

    def setUp(self):
        """Set up test fixtures."""
        self.factory = RequestFactory()
        self.uid_alice = "uid_alice_12345"
        
        self.auth_user_alice: AuthenticatedUser = {
            "uid": self.uid_alice,
            "email": "alice@example.com",
            "email_verified": True,
            "display_name": "Alice",
            "photo_url": None,
        }

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.upload_profile_photo")
    def test_photo_upload_saves_to_storage_and_firestore(self, mock_upload, mock_verify_token):
        """
        Test that uploaded photo is saved to Firebase Storage
        and URL is saved to Firestore.
        """
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        # Create a fake image file
        image_content = b"fake_image_data_jpeg"
        uploaded_file = SimpleUploadedFile(
            name="test_photo.jpg",
            content=image_content,
            content_type="image/jpeg",
        )

        mock_profile = Mock(spec=UserProfile)
        mock_profile.to_dict.return_value = {
            "uid": self.uid_alice,
            "profilePhotoUrl": "https://firebasestorage.googleapis.com/v0/b/krontech-7fbdb.appspot.com/o/users%2Fuid_alice_12345%2Fprofile%2F20250508_120000_test_photo.jpg?alt=media",
        }
        mock_upload.return_value = mock_profile

        request = self.factory.post(
            "/api/profile/photo/",
            HTTP_AUTHORIZATION="Bearer fake-token",
        )
        request.FILES["photo"] = uploaded_file
        request.auth_user = self.auth_user_alice
        request.auth_user_id = self.uid_alice

        response = upload_profile_photo(request)

        self.assertEqual(response.status_code, 201)
        
        # Verify upload_profile_photo was called with correct parameters
        mock_upload.assert_called_once()
        call_args = mock_upload.call_args
        
        # Verify UID is from token
        self.assertEqual(call_args[1]["uid"], self.uid_alice)
        
        # Verify file content was passed
        self.assertEqual(call_args[1]["file_content"], image_content)
        
        # Verify filename
        self.assertEqual(call_args[1]["filename"], "test_photo.jpg")
        
        # Verify content type
        self.assertEqual(call_args[1]["content_type"], "image/jpeg")

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.upload_profile_photo")
    def test_photo_upload_with_invalid_file_type(self, mock_upload, mock_verify_token):
        """Test that invalid file types are rejected."""
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        mock_upload.side_effect = ValueError(
            "Invalid file type. Allowed types: image/jpeg, image/png, image/webp, image/gif"
        )

        # Try to upload a non-image file
        invalid_file = SimpleUploadedFile(
            name="document.pdf",
            content=b"PDF content here",
            content_type="application/pdf",
        )

        request = self.factory.post(
            "/api/profile/photo/",
            HTTP_AUTHORIZATION="Bearer fake-token",
        )
        request.FILES["photo"] = invalid_file
        request.auth_user = self.auth_user_alice
        request.auth_user_id = self.uid_alice

        response = upload_profile_photo(request)

        self.assertEqual(response.status_code, 400)
        data = json.loads(response.content)
        self.assertIn("Invalid file type", data["error"])

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.upload_profile_photo")
    def test_photo_upload_with_oversized_file(self, mock_upload, mock_verify_token):
        """Test that files larger than 5MB are rejected."""
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        mock_upload.side_effect = ValueError("File size exceeds 5MB limit")

        # Create a file larger than 5MB
        large_file = SimpleUploadedFile(
            name="large_photo.jpg",
            content=b"x" * (6 * 1024 * 1024),  # 6MB
            content_type="image/jpeg",
        )

        request = self.factory.post(
            "/api/profile/photo/",
            HTTP_AUTHORIZATION="Bearer fake-token",
        )
        request.FILES["photo"] = large_file
        request.auth_user = self.auth_user_alice
        request.auth_user_id = self.uid_alice

        response = upload_profile_photo(request)

        self.assertEqual(response.status_code, 400)
        data = json.loads(response.content)
        self.assertIn("exceeds 5MB", data["error"])

    @patch("common.authentication.firebase_auth.verify_token")
    def test_photo_upload_without_file(self, mock_verify_token):
        """Test that upload fails if no file is provided."""
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        request = self.factory.post(
            "/api/profile/photo/",
            HTTP_AUTHORIZATION="Bearer fake-token",
        )
        request.auth_user = self.auth_user_alice
        request.auth_user_id = self.uid_alice

        response = upload_profile_photo(request)

        self.assertEqual(response.status_code, 400)
        data = json.loads(response.content)
        self.assertIn("No file provided", data["error"])

    @patch("common.authentication.firebase_auth.verify_token")
    @patch("apps.core.views.ProfileService.upload_profile_photo")
    def test_photo_upload_uid_from_token_not_body(self, mock_upload, mock_verify_token):
        """
        SECURITY TEST: Photo upload uses UID from token, not from body.
        
        This prevents a user from uploading a photo for another user.
        """
        # Mock Firebase token verification
        mock_verify_token.return_value = self.auth_user_alice
        
        # Create a normal image file
        image_content = b"fake_image_data_jpeg"
        uploaded_file = SimpleUploadedFile(
            name="test_photo.jpg",
            content=image_content,
            content_type="image/jpeg",
        )

        mock_profile = Mock(spec=UserProfile)
        mock_profile.to_dict.return_value = {
            "uid": self.uid_alice,
            "profilePhotoUrl": "https://firebasestorage.googleapis.com/...",
        }
        mock_upload.return_value = mock_profile

        request = self.factory.post(
            "/api/profile/photo/",
            HTTP_AUTHORIZATION="Bearer fake-token",
        )
        request.FILES["photo"] = uploaded_file
        request.auth_user = self.auth_user_alice
        request.auth_user_id = self.uid_alice

        response = upload_profile_photo(request)

        self.assertEqual(response.status_code, 201)
        
        # Verify the UID used was from the token
        call_args = mock_upload.call_args
        self.assertEqual(call_args[1]["uid"], self.uid_alice)


class ProfileServiceFieldWhitelistTest(TestCase):
    """Tests for ProfileService field whitelist validation."""

    @patch("apps.core.models.UserProfile.get_by_uid")
    def test_service_filters_non_allowed_fields(self, mock_get):
        """Test that ProfileService filters non-allowed fields."""
        from common.services.profile_service import ProfileService

        # Mock the profile instance with update method
        mock_profile = Mock(spec=UserProfile)
        mock_profile.uid = "test_uid"
        mock_profile.update = Mock(return_value=True)
        mock_get.return_value = mock_profile

        # Try to update with mixed allowed/non-allowed fields
        update_data = {
            "firstName": "John",  # Allowed
            "email": "hacker@example.com",  # Not allowed
            "city": "Bucharest",  # Allowed
            "password": "new_password",  # Not allowed
        }

        ProfileService.update_profile("test_uid", update_data)

        # Verify only allowed fields were passed to profile.update()
        mock_profile.update.assert_called_once()
        call_args = mock_profile.update.call_args[0][0]
        
        self.assertIn("firstName", call_args)
        self.assertIn("city", call_args)
        self.assertNotIn("email", call_args)
        self.assertNotIn("password", call_args)

    def test_allowed_fields_constant(self):
        """Test that ALLOWED_UPDATE_FIELDS contains expected fields."""
        from common.services.profile_service import ProfileService

        expected_fields = {
            "firstName",
            "lastName",
            "dateOfBirth",
            "gender",
            "country",
            "city",
            "street",
        }

        self.assertEqual(ProfileService.ALLOWED_UPDATE_FIELDS, expected_fields)


class UserProfileModelTest(TestCase):
    """Tests for UserProfile model fields."""

    @patch("apps.core.models.FirestoreService")
    def test_profile_has_new_fields_properties(self, mock_firestore):
        """Test that UserProfile has properties for all new fields."""
        profile = UserProfile(
            uid="test_uid",
            data={
                "firstName": "John",
                "lastName": "Doe",
                "dateOfBirth": "1990-01-15",
                "gender": "M",
                "country": "Romania",
                "city": "Bucharest",
                "street": "Main St 123",
                "profilePhotoUrl": "https://example.com/photo.jpg",
            }
        )

        self.assertEqual(profile.first_name, "John")
        self.assertEqual(profile.last_name, "Doe")
        self.assertEqual(profile.date_of_birth, "1990-01-15")
        self.assertEqual(profile.gender, "M")
        self.assertEqual(profile.country, "Romania")
        self.assertEqual(profile.city, "Bucharest")
        self.assertEqual(profile.street, "Main St 123")
        self.assertEqual(profile.profile_photo_url, "https://example.com/photo.jpg")

    @patch("apps.core.models.FirestoreService")
    def test_profile_to_dict_includes_all_fields(self, mock_firestore):
        """Test that to_dict() includes all fields."""
        data = {
            "firstName": "Jane",
            "lastName": "Smith",
            "email": "jane@example.com",
            "profilePhotoUrl": "https://example.com/jane.jpg",
        }
        profile = UserProfile(uid="test_uid", data=data)

        result = profile.to_dict()

        self.assertEqual(result["uid"], "test_uid")
        self.assertEqual(result["firstName"], "Jane")
        self.assertEqual(result["lastName"], "Smith")
        self.assertEqual(result["email"], "jane@example.com")
        self.assertEqual(result["profilePhotoUrl"], "https://example.com/jane.jpg")

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
