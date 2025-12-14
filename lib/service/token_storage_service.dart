import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service để quản lý lưu trữ token an toàn
class TokenStorageService {
  static const _storage = FlutterSecureStorage();
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  /// Lưu access token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Lấy access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Xóa access token
  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Lưu refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Lấy refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Xóa refresh token
  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Lưu user ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Lấy user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Xóa user ID
  static Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  /// Xóa tất cả tokens (logout)
  static Future<void> clearAll() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
      deleteUserId(),
    ]);
  }

  /// Check if user is logged in (có access token)
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
