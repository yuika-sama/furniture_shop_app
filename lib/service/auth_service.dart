import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// [POST] /api/auth/register - Đăng ký tài khoản
  /// 
  /// Backend expects: email, password, fullName, phone
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Đăng ký thành công",
  ///   "user": { "_id", "email", "fullName", "phone", "role" },
  ///   "token": "jwt_token_here"
  /// }
  /// ```
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phone': phone,
        },
      );

      if (response.data['success'] == true) {
        final authResponse = AuthResponse.fromJson(response.data);
        
        // Lưu token vào secure storage
        if (authResponse.token != null) {
          await _apiClient.storage.write(
            key: 'auth_token',
            value: authResponse.token,
          );
          // Lưu thêm user info
          await _apiClient.storage.write(
            key: 'user_id',
            value: authResponse.user?.id,
          );
          await _apiClient.storage.write(
            key: 'user_email',
            value: authResponse.user?.email,
          );
        }

        return {
          'success': true,
          'message': authResponse.message,
          'user': authResponse.user,
          'token': authResponse.token,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Đăng ký thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [POST] /api/auth/login - Đăng nhập
  /// 
  /// Backend expects: email, password
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Đăng nhập thành công",
  ///   "user": { "_id", "email", "fullName", "phone", "role" },
  ///   "token": "jwt_token_here"
  /// }
  /// ```
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final authResponse = AuthResponse.fromJson(response.data);
        
        // Lưu token vào secure storage
        if (authResponse.token != null) {
          await _apiClient.storage.write(
            key: 'auth_token',
            value: authResponse.token,
          );
          // Lưu thêm user info
          await _apiClient.storage.write(
            key: 'user_id',
            value: authResponse.user?.id,
          );
          await _apiClient.storage.write(
            key: 'user_email',
            value: authResponse.user?.email,
          );
          await _apiClient.storage.write(
            key: 'user_role',
            value: authResponse.user?.role,
          );
        }

        return {
          'success': true,
          'message': authResponse.message,
          'user': authResponse.user,
          'token': authResponse.token,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Đăng nhập thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [GET] /api/auth/me - Lấy thông tin user hiện tại (Protected route)
  /// 
  /// Cần Authorization header với Bearer token
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy thông tin user thành công",
  ///   "user": { ... }
  /// }
  /// ```
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _apiClient.dio.get('/api/auth/me');

      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['user']);

        return {
          'success': true,
          'user': user,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không thể lấy thông tin user',
      };
    } on DioException catch (e) {
      // Nếu 401 (Unauthorized), xóa token
      if (e.response?.statusCode == 401) {
        await logout();
      }
      
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [POST] /api/auth/forgot-password - Quên mật khẩu
  /// 
  /// Backend expects: email
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Liên kết đặt lại mật khẩu đã được gửi đến email của bạn"
  /// }
  /// ```
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [POST] /api/auth/reset-password - Đặt lại mật khẩu
  /// 
  /// Backend expects: token, newPassword
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Đặt lại mật khẩu thành công. Bạn có thể đăng nhập với mật khẩu mới."
  /// }
  /// ```
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// Logout - Xóa token khỏi storage
  Future<void> logout() async {
    await _apiClient.storage.delete(key: 'auth_token');
    await _apiClient.storage.delete(key: 'user_id');
    await _apiClient.storage.delete(key: 'user_email');
    await _apiClient.storage.delete(key: 'user_role');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiClient.storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  /// Get current token
  Future<String?> getToken() async {
    return await _apiClient.storage.read(key: 'auth_token');
  }

  /// Get current user role
  Future<String?> getUserRole() async {
    return await _apiClient.storage.read(key: 'user_role');
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }
}