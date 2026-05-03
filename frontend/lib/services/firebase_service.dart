import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Service for managing Firestore operations
class FirebaseService {
  static const String usersCollection = 'users';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current authenticated user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Sign in anonymously if not already authenticated
  Future<User?> signInAnonymously() async {
    try {
      // Check if already authenticated
      if (_firebaseAuth.currentUser != null) {
        return _firebaseAuth.currentUser;
      }

      final result = await _firebaseAuth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  /// Save user data to Firestore
  Future<bool> saveUserToFirestore(UserModel user) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Use Firebase UID as document ID
      await _firestore.collection(usersCollection).doc(currentUser.uid).set({
        ...user.toMap(),
        'firebaseUid': currentUser.uid,
        'email': currentUser.email,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update collection statistics
      await _updateCollectionStatistics();

      return true;
    } catch (e) {
      throw Exception('Failed to save user to Firestore: $e');
    }
  }

  /// Update collection statistics metadata
  Future<void> _updateCollectionStatistics() async {
    try {
      final collectionRef = _firestore.collection(usersCollection);
      final count = await collectionRef.count().get();

      await collectionRef.doc('_metadata').update({
        'totalDocuments': count.count,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserFromFirestore() async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(usersCollection)
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user from Firestore: $e');
    }
  }

  /// Update specific user fields
  Future<bool> updateUserInFirestore(Map<String, dynamic> data) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection(usersCollection).doc(currentUser.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to update user in Firestore: $e');
    }
  }

  /// Delete user document from Firestore
  Future<bool> deleteUserFromFirestore() async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(usersCollection)
          .doc(currentUser.uid)
          .delete();

      return true;
    } catch (e) {
      throw Exception('Failed to delete user from Firestore: $e');
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExistsInFirestore() async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      final doc = await _firestore
          .collection(usersCollection)
          .doc(currentUser.uid)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }
}
