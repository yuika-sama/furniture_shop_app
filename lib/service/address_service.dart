import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

/// Address Service - Quản lý địa chỉ người dùng
class AddressService {
  final ApiClient _apiClient;

  AddressService(this._apiClient);

  /// [GET] /api/users/me/address - Lấy danh sách địa chỉ
  Future<Map<String, dynamic>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiConstants.userAddress);
      
      return {
        'success': true,
        'addresses': response.data['addresses'] ?? [],
        'message': 'Lấy danh sách địa chỉ thành công',
      };
    } catch (e) {
      debugPrint('Error getting addresses: $e');
      return {
        'success': false,
        'addresses': [],
        'message': 'Không thể lấy danh sách địa chỉ: ${e.toString()}',
      };
    }
  }

  /// [POST] /api/users/me/address - Thêm địa chỉ mới
  Future<Map<String, dynamic>> createAddress({
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

      return {
        'success': true,
        'addresses': response.data['addresses'] ?? [],
        'message': 'Thêm địa chỉ thành công',
      };
    } catch (e) {
      debugPrint('Error creating address: $e');
      return {
        'success': false,
        'message': 'Không thể thêm địa chỉ: ${e.toString()}',
      };
    }
  }

  /// [PUT] /api/users/me/address/:id - Cập nhật địa chỉ
  Future<Map<String, dynamic>> updateAddress({
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

      final response = await _apiClient.put(
        '${ApiConstants.userAddress}/$addressId',
        data: data,
      );

      return {
        'success': true,
        'addresses': response.data['addresses'] ?? [],
        'message': 'Cập nhật địa chỉ thành công',
      };
    } catch (e) {
      debugPrint('Error updating address: $e');
      return {
        'success': false,
        'message': 'Không thể cập nhật địa chỉ: ${e.toString()}',
      };
    }
  }

  /// [DELETE] /api/users/me/address/:id - Xóa địa chỉ
  Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.userAddress}/$addressId',
      );

      return {
        'success': true,
        'addresses': response.data['addresses'] ?? [],
        'message': 'Xóa địa chỉ thành công',
      };
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return {
        'success': false,
        'message': 'Không thể xóa địa chỉ: ${e.toString()}',
      };
    }
  }
}
