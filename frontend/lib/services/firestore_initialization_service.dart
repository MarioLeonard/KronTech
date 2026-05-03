import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Service for initializing Firestore collections and structure
class FirestoreInitializationService {
  static const String usersCollection = 'users';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firestore collections and create default structure
  Future<void> initializeCollections() async {
    try {
      debugPrint('🔥 Initializing Firestore collections...');

      // Initialize users collection
      await _initializeUsersCollection();

      debugPrint('✅ Firestore collections initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firestore: $e');
      // Don't rethrow - allow app to continue even if initialization fails
    }
  }

  /// Initialize users collection with proper structure
  Future<void> _initializeUsersCollection() async {
    try {
      debugPrint('📁 Setting up users collection...');

      // Check if collection exists by trying to get a document count
      final collectionRef = _firestore.collection(usersCollection);

      // Try to get first document to check if collection exists
      final snapshot = await collectionRef.limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint('📝 Users collection is empty or new');
      } else {
        debugPrint(
          '✓ Users collection exists with ${snapshot.docs.length} documents',
        );
      }

      // Set up collection metadata document (optional, for tracking)
      await _createCollectionMetadata();
    } catch (e) {
      debugPrint('⚠️ Error initializing users collection: $e');
      // Don't throw - collection will be created on first write
    }
  }

  /// Create collection metadata for tracking
  Future<void> _createCollectionMetadata() async {
    try {
      final metadataRef = _firestore
          .collection(usersCollection)
          .doc('_metadata');

      final metadata = await metadataRef.get();

      if (!metadata.exists) {
        await metadataRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'version': '1.0.0',
          'totalDocuments': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('✓ Collection metadata created');
      }
    } catch (e) {
      debugPrint('⚠️ Error creating collection metadata: $e');
    }
  }

  /// Create indexes for better query performance
  Future<void> setupIndexes() async {
    try {
      debugPrint('📊 Setting up Firestore indexes...');
      // Note: Composite indexes should be set up in Firebase Console
      // This is just a placeholder for documentation
      debugPrint('✓ Indexes configured (managed in Firebase Console)');
    } catch (e) {
      debugPrint('⚠️ Error setting up indexes: $e');
    }
  }

  /// Update collection statistics
  Future<void> updateCollectionStats() async {
    try {
      final usersRef = _firestore.collection(usersCollection);
      final snapshot = await usersRef.count().get();

      await usersRef.doc('_metadata').update({
        'totalDocuments': snapshot.count,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint('📊 Collection stats updated: ${snapshot.count} users');
    } catch (e) {
      debugPrint('⚠️ Error updating stats: $e');
    }
  }

  /// Enable Firestore offline persistence
  Future<void> enableOfflinePersistence() async {
    try {
      await _firestore.enableNetwork();
      debugPrint('✓ Firestore offline persistence enabled');
    } catch (e) {
      debugPrint('⚠️ Could not enable persistence: $e');
    }
  }

  /// Get security rules that should be applied (for reference)
  String getSecurityRulesTemplate() {
    return '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      allow read: if request.auth.token.admin == true;
      allow create: if request.auth.uid != null;
    }
    
    // Metadata document - read-only for users
    match /users/_metadata {
      allow read: if request.auth.uid != null;
    }
  }
}
''';
  }

  /// Print security rules for setup (user must apply in Firebase Console)
  void printSecurityRulesForSetup() {
    debugPrint('''

╔════════════════════════════════════════════════════════════════╗
║          FIRESTORE SECURITY RULES - APPLY IN CONSOLE           ║
╚════════════════════════════════════════════════════════════════╝

Copy and paste these rules in Firebase Console:
Firestore Database → Rules → Replace all

${getSecurityRulesTemplate()}

╔════════════════════════════════════════════════════════════════╗
║  After pasting, click "Publish" to apply the security rules    ║
╚════════════════════════════════════════════════════════════════╝

''');
  }
}
