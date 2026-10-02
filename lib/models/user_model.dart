import 'package:firebase_auth/firebase_auth.dart';

/// Model: Represents the authenticated user.
class UserModel {
  final String uid;
  final String email;
  final String displayName;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  /// Constructs a [UserModel] from a Firebase [User] object.
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName?.isNotEmpty == true
          ? firebaseUser.displayName!
          : firebaseUser.email?.split('@').first ?? 'User',
    );
  }
}
