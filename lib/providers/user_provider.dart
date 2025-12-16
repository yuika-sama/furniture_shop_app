import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../service/user_service.dart';
import 'dart:io';

/// User Provider - Quản lý state cho user profile và addresses
class UserProvider extends ChangeNotifier {
  final UserService _userService;

  UserProvider(this._userService);

  // State
  UserModel? _currentUser;
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUser => _currentUser != null;

  /// Load current user profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.getProfile();
      _addresses = _currentUser?.address ?? [];
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      _addresses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.updateProfile(
        fullName: fullName,
        phone: phone,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Upload avatar
  Future<bool> uploadAvatar(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.uploadAvatar(imageFile);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Add new address
  Future<bool> addAddress({
    required String fullName,
    required String phone,
    required String province,
    required String district,
    required String ward,
    required String address,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAddresses = await _userService.addAddress(
        fullName: fullName,
        phone: phone,
        province: province,
        district: district,
        ward: ward,
        address: address,
        isDefault: isDefault,
      );

      _addresses = updatedAddresses;

      // Update current user's address list
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: _currentUser!.fullName,
          phone: _currentUser!.phone,
          role: _currentUser!.role,
          avatar: _currentUser!.avatar,
          address: _addresses,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Update address
  Future<bool> updateAddress(
    String addressId, {
    String? fullName,
    String? phone,
    String? province,
    String? district,
    String? ward,
    String? address,
    bool? isDefault,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAddresses = await _userService.updateAddress(
        addressId: addressId,
        fullName: fullName,
        phone: phone,
        province: province,
        district: district,
        ward: ward,
        address: address,
        isDefault: isDefault,
      );

      _addresses = updatedAddresses;

      // Update current user's address list
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: _currentUser!.fullName,
          phone: _currentUser!.phone,
          role: _currentUser!.role,
          avatar: _currentUser!.avatar,
          address: _addresses,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Delete address
  Future<bool> deleteAddress(String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.deleteAddress(addressId);
      _addresses.removeWhere((a) => a.id == addressId);

      // Update current user's address list
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: _currentUser!.fullName,
          phone: _currentUser!.phone,
          role: _currentUser!.role,
          avatar: _currentUser!.avatar,
          address: _addresses,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    return await updateAddress(addressId, isDefault: true);
  }

  /// Get default address
  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  /// Clear all state
  void clear() {
    _currentUser = null;
    _addresses = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
