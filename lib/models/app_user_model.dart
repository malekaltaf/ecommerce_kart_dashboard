import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a user document from the Firestore `users` collection.
class AppUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  AppUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  factory AppUserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '—',
      displayName: (data['displayName'] as String?)?.isNotEmpty == true
          ? data['displayName'] as String
          : (data['name'] as String?) ??
              (data['email'] as String?)?.split('@').first ??
              '—',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
