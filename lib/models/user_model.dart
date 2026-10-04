/// Model: Represents the authenticated user.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String userrole;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.userrole = 'user',
  });

  /// Constructs a [UserModel] from a Map (e.g., Firestore document data).
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? (data['email'] != null ? data['email'].toString().split('@').first : 'User'),
      userrole: data['userrole'] ?? 'user',
    );
  }
}
