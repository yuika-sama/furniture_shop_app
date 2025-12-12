import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // ========== USER PROFILE ROUTES ==========

  /// [GET] /api/users/me - Lấy thông tin người dùng hiện tại
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// [PUT] /api/users/me - Cập nhật thông tin người dùng
  /// 
  /// Body:
  /// - fullName: Họ tên (optional)
  /// - phone: Số điện thoại (optional)
  /// - avatar: URL avatar (optional)
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatar,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['fullName'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      if (data.isEmpty) {
        throw Exception('Vui lòng cung cấp thông tin cần cập nhật');
      }

      final response = await _apiClient.put(
        ApiConstants.userProfile,
        data: data,
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// [POST] /api/users/me/avatar - Upload avatar
  /// 
  /// Requires: Image file (jpg, jpeg, png, gif, webp)
  /// Max size: 10MB
  /// 
  /// Returns: UserModel with updated avatar
  Future<UserModel> uploadAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      // Validate file extension
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
        throw Exception('Định dạng file không được hỗ trợ');
      }

      // Create form data
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', fileExtension),
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.userAvatar,
        data: formData,
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// [PUT] /api/users/me/password - Đổi mật khẩu
  /// 
  /// Requirements:
  /// - currentPassword phải đúng
  /// - newPassword phải khác currentPassword
  /// - newPassword ít nhất 6 ký tự
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw Exception('Vui lòng cung cấp đầy đủ thông tin');
      }

      if (currentPassword == newPassword) {
        throw Exception('Mật khẩu mới phải khác mật khẩu hiện tại');
      }

      if (newPassword.length < 6) {
        throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
      }

      await _apiClient.put(
        ApiConstants.userPassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // ========== ADDRESS MANAGEMENT ==========

  /// [GET] /api/users/me/address - Lấy danh sách địa chỉ
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiConstants.userAddress);
      final List<dynamic> addresses = response.data['addresses'];
      return addresses.map((addr) => AddressModel.fromJson(addr)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// [POST] /api/users/me/address - Thêm địa chỉ mới
  /// 
  /// Body:
  /// - fullName: Tên người nhận
  /// - phone: Số điện thoại
  /// - province: Tỉnh/Thành phố
  /// - district: Quận/Huyện
  /// - ward: Phường/Xã
  /// - address: Địa chỉ cụ thể
  /// - isDefault: Đặt làm địa chỉ mặc định
  /// 
  /// Note: Nếu isDefault = true, tất cả địa chỉ khác sẽ bị bỏ default
  Future<List<AddressModel>> addAddress({
    required String fullName,
    required String phone,
    required String province,
    required String district,
    required String ward,
    required String address,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.userAddress,
        data: {
          'fullName': fullName,
          'phone': phone,
          'province': province,
          'district': district,
          'ward': ward,
          'address': address,
          'isDefault': isDefault,
        },
      );

      final List<dynamic> addresses = response.data['addresses'];
      return addresses.map((addr) => AddressModel.fromJson(addr)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// [PUT] /api/users/me/address/:id - Cập nhật địa chỉ
  /// 
  /// All fields are optional
  Future<List<AddressModel>> updateAddress({
    required String addressId,
    String? fullName,
    String? phone,
    String? province,
    String? district,
    String? ward,
    String? address,
    bool? isDefault,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['fullName'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (province != null) data['province'] = province;
      if (district != null) data['district'] = district;
      if (ward != null) data['ward'] = ward;
      if (address != null) data['address'] = address;
      if (isDefault != null) data['isDefault'] = isDefault;

      if (data.isEmpty) {
        throw Exception('Vui lòng cung cấp thông tin cần cập nhật');
      }

      final response = await _apiClient.put(
        '${ApiConstants.userAddress}/$addressId',
        data: data,
      );

      final List<dynamic> addresses = response.data['addresses'];
      return addresses.map((addr) => AddressModel.fromJson(addr)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/users/me/address/:id - Xóa địa chỉ
  Future<List<AddressModel>> deleteAddress(String addressId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.userAddress}/$addressId',
      );

      final List<dynamic> addresses = response.data['addresses'];
      return addresses.map((addr) => AddressModel.fromJson(addr)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ========== ADMIN ROUTES ==========

  /// [GET] /api/admin/users - Lấy tất cả users (Admin)
  /// 
  /// Params:
  /// - page: Trang hiện tại (default: 1)
  /// - limit: Số user mỗi trang (default: 10)
  /// - search: Tìm kiếm theo name, email, phone
  /// - role: Filter theo role ('user' hoặc 'admin')
  /// - sortBy: Sắp xếp (default: -createdAt)
  Future<UsersResponse> getAllUsersAdmin({
    int page = 1,
    int limit = 10,
    String? search,
    String? role,
    String sortBy = '-createdAt',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && (role == 'user' || role == 'admin')) 'role': role,
      };

      final response = await _apiClient.get(
        ApiConstants.adminUsers,
        queryParameters: queryParams,
      );

      return UsersResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// [GET] /api/admin/users/:id - Lấy user theo ID (Admin)
  Future<UserModel> getUserByIdAdmin(String userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.adminUsers}/$userId');
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// [POST] /api/admin/users - Tạo user mới (Admin)
  /// 
  /// Body:
  /// - fullName: Họ tên (required)
  /// - email: Email (required, unique)
  /// - password: Mật khẩu (required, min 6 chars)
  /// - role: 'user' hoặc 'admin' (default: 'user')
  /// - phone: Số điện thoại (optional)
  /// - avatar: URL avatar (optional)
  /// - address: List địa chỉ (optional)
  Future<UserModel> createUserAdmin({
    required String fullName,
    required String email,
    required String password,
    String role = 'user',
    String? phone,
    String? avatar,
    List<AddressModel>? address,
  }) async {
    try {
      if (password.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      }

      final data = {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        if (address != null) 'address': address.map((a) => a.toJson()).toList(),
      };

      final response = await _apiClient.post(
        ApiConstants.adminUsers,
        data: data,
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// [PUT] /api/admin/users/:id - Cập nhật user (Admin)
  /// 
  /// All fields are optional
  /// Can update password (will be hashed)
  Future<UserModel> updateUserByIdAdmin({
    required String userId,
    String? fullName,
    String? phone,
    String? role,
    String? avatar,
    List<AddressModel>? address,
    String? password,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['fullName'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (role != null) data['role'] = role;
      if (avatar != null) data['avatar'] = avatar;
      if (address != null) data['address'] = address.map((a) => a.toJson()).toList();
      if (password != null) {
        if (password.length < 6) {
          throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
        }
        data['password'] = password;
      }

      if (data.isEmpty) {
        throw Exception('Vui lòng cung cấp thông tin cần cập nhật');
      }

      final response = await _apiClient.put(
        '${ApiConstants.adminUsers}/$userId',
        data: data,
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/admin/users/:id - Xóa user (Admin)
  Future<void> deleteUserByIdAdmin(String userId) async {
    try {
      await _apiClient.delete('${ApiConstants.adminUsers}/$userId');
    } catch (e) {
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========

  /// Set default address
  Future<List<AddressModel>> setDefaultAddress(String addressId) async {
    return await updateAddress(
      addressId: addressId,
      isDefault: true,
    );
  }

  /// Validate phone number (simple validation)
  bool isValidPhone(String phone) {
    // Vietnamese phone: 10 digits, starts with 0
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Validate email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

// ========== MODELS ==========

/// Users response with pagination (Admin)
class UsersResponse {
  final List<UserModel> users;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  UsersResponse({
    required this.users,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      users: json['users'] != null
          ? List<UserModel>.from(
              json['users'].map((x) => UserModel.fromJson(x)))
          : [],
      page: json['pagination']?['page'] ?? 1,
      limit: json['pagination']?['limit'] ?? 10,
      total: json['pagination']?['total'] ?? 0,
      totalPages: json['pagination']?['totalPages'] ?? 0,
    );
  }

  bool get hasMore => page < totalPages;
}
