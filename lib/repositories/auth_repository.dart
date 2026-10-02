import '../models/user_model.dart';

/// Repository / Service layer that performs the actual authentication logic.
/// In a real app this would make an API call.
class AuthRepository {
  /// Simulates a login check. Returns [UserModel] on success, throws on failure.
  Future<UserModel> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Hardcoded demo credentials
    if (username == 'admin' && password == 'admin123') {
      return UserModel(username: username, password: password);
    } else {
      throw Exception('Invalid username or password.');
    }
  }
}
