import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Repository layer that wraps Firebase Authentication.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Signs in with [email] and [password] using Firebase Authentication.
  /// Returns a [UserModel] on success, throws a human-readable message on failure.
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Authentication failed. Please try again.');
      }
      return UserModel.fromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    }
  }

  /// Signs out the current user.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Maps Firebase error codes to user-friendly messages.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}
