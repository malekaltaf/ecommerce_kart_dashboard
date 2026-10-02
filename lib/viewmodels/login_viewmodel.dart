import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Enum describing the current state of the login operation.
enum LoginState { idle, loading, success, error }

/// ViewModel for the Login screen.
/// Extends [ChangeNotifier] so the View can listen to state changes.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  LoginState _state = LoginState.idle;
  LoginState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Toggles password visibility.
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Validates inputs and initiates login.
  Future<void> login(String username, String password) async {
    // Basic validation
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Username and password cannot be empty.';
      _state = LoginState.error;
      notifyListeners();
      return;
    }

    _state = LoginState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _user = await _authRepository.login(username.trim(), password.trim());
      _state = LoginState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = LoginState.error;
    }

    notifyListeners();
  }

  /// Resets the view model back to its idle state.
  void reset() {
    _state = LoginState.idle;
    _errorMessage = '';
    _user = null;
    notifyListeners();
  }
}
