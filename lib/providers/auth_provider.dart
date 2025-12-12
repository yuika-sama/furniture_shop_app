import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../service/api_client.dart';
import '../service/auth_service.dart';

/// Auth State Provider
/// Quản lý trạng thái authentication trong app
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService(ApiClient());
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Initialize - Check if user is logged in and load user data
  Future<void> initialize() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await loadCurrentUser();
    }
  }

  /// Load current user from API
  Future<bool> loadCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.getMe();

    _isLoading = false;

    if (result['success'] == true) {
      _currentUser = result['user'] as UserModel;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  /// Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _currentUser = result['user'] as UserModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
      _currentUser = null;
    }

    notifyListeners();
    return result;
  }

  /// Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _currentUser = result['user'] as UserModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
      _currentUser = null;
    }

    notifyListeners();
    return result;
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await _authService.forgotPassword(email: email);
  }

  /// Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _authService.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
