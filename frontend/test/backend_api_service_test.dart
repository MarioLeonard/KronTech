import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/backend_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'syncAuthenticatedUser sends token and returns backend profile',
    () async {
      final service = BackendApiService(
        baseUrl: 'http://127.0.0.1:8000',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.toString(), 'http://127.0.0.1:8000/api/signup/');
          expect(request.headers['Authorization'], 'Bearer firebase-token');
          expect(request.body, isEmpty);

          return http.Response('''
          {
            "profile": {
              "uid": "user-1",
              "email": "test@example.com",
              "display_name": "Test User",
              "email_verified": true,
              "hasCompletedOnboarding": false
            }
          }
          ''', 201);
        }),
      );

      final profile = await service.syncAuthenticatedUser('firebase-token');

      expect(profile.uid, 'user-1');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.emailVerified, isTrue);
      expect(profile.hasCompletedOnboarding, isFalse);
    },
  );

  test('completeOnboarding sends token and payload', () async {
    final service = BackendApiService(
      baseUrl: 'http://127.0.0.1:8000',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'http://127.0.0.1:8000/api/onboarding/complete/',
        );
        expect(request.headers['Authorization'], 'Bearer firebase-token');
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(request.body, contains('"firstName":"Test"'));

        return http.Response('''
          {
            "profile": {
              "uid": "user-1",
              "email": "test@example.com",
              "display_name": "Test User",
              "hasCompletedOnboarding": true
            }
          }
          ''', 200);
      }),
    );

    final profile = await service.completeOnboarding(
      idToken: 'firebase-token',
      user: UserModel(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        dateOfBirth: DateTime(2000),
        gender: 'Other',
        country: 'Romania',
        city: 'Bucharest',
        street: 'Main Street 1',
        zipCode: '',
        interests: const [],
        enableNotifications: false,
        acceptPrivacyPolicy: true,
      ),
    );

    expect(profile.hasCompletedOnboarding, isTrue);
  });

  test(
    'syncAuthenticatedUser surfaces backend errors as auth errors',
    () async {
      final service = BackendApiService(
        client: MockClient((request) async {
          return http.Response('{"error": "Registration failed"}', 500);
        }),
      );

      expect(
        () => service.syncAuthenticatedUser('firebase-token'),
        throwsA(isA<AuthException>()),
      );
    },
  );
}
