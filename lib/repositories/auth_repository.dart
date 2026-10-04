import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository layer that authenticates against Firestore 'users' collection.
class AuthRepository {
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Signs in by checking the [email] and verifying the SHA-256 hashed [password].
  /// Returns a [UserModel] on success, throws a human-readable message on failure.
  Future<UserModel> login(String email, String password) async {
    try {
      // Fetch the user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Incorrect email or password. Please try again.');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final storedPassword = userData['password'] as String?;

      // Hash the provided password with SHA-256
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      final hashedInputPassword = digest.toString();

      // Verify the hashed password
      if (storedPassword != hashedInputPassword) {
        throw Exception('Incorrect email or password. Please try again.');
      }

      final userrole = userData['userrole'] as String? ?? 'user';

      if (userrole != 'admin') {
        throw Exception('Access denied. Admin role required.');
      }

      return UserModel.fromMap(userData, userDoc.id);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Authentication failed. Please try again.');
    }
  }

  /// Signs out the current user.
  Future<void> logout() async {
    // With custom Firestore auth, logout is typically handled by clearing 
    // the user state in the ViewModel, so no action is required here.
  }
}
