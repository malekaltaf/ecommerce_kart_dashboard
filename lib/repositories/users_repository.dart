import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user_model.dart';

/// Fetches user records from the Firestore `users` collection.
///
/// NOTE: Firebase Auth's Admin SDK is required to list auth accounts directly.
/// The industry-standard dashboard pattern is to mirror user data into Firestore
/// (e.g. via a Cloud Function on user creation). This repository reads that mirror.
class UsersRepository {
  final FirebaseFirestore _db;

  UsersRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Returns all documents from the `users` collection.
  Future<List<AppUserModel>> fetchAllUsers() async {
    final snapshot = await _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(AppUserModel.fromDoc).toList();
  }
}
