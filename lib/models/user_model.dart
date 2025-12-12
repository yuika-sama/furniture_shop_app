/// User Model - Map với User schema trong backend
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role; // 'user' hoặc 'admin'
  final String? avatar;
  final List<AddressModel> address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.role = 'user',
    this.avatar,
    this.address = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      address: json['address'] != null
          ? List<AddressModel>.from(
              json['address'].map((x) => AddressModel.fromJson(x)))
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'address': address.map((x) => x.toJson()).toList(),
    };
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Get display name (fallback to email if no fullName)
  String get displayName => fullName.isNotEmpty ? fullName : email;

  /// Get avatar URL or default
  String getAvatarUrl(String baseUrl) {
    if (avatar == null || avatar!.isEmpty) {
      return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&size=200';
    }
    if (avatar!.startsWith('http')) return avatar!;
    return '$baseUrl/$avatar';
  }

  /// Get default address
  AddressModel? get defaultAddress {
    try {
      return address.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return address.isNotEmpty ? address.first : null;
    }
  }

  /// Has addresses
  bool get hasAddresses => address.isNotEmpty;
}

/// Address Model - Địa chỉ giao hàng
class AddressModel {
  final String? id;
  final String? fullName;
  final String? phone;
  final String? province;
  final String? district;
  final String? ward;
  final String? address;
  final bool isDefault;

  AddressModel({
    this.id,
    this.fullName,
    this.phone,
    this.province,
    this.district,
    this.ward,
    this.address,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'],
      fullName: json['fullName'],
      phone: json['phone'],
      province: json['province'],
      district: json['district'],
      ward: json['ward'],
      address: json['address'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'fullName': fullName,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'address': address,
      'isDefault': isDefault,
    };
  }

  /// Get full address string
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (ward != null && ward!.isNotEmpty) parts.add(ward!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (province != null && province!.isNotEmpty) parts.add(province!);
    return parts.join(', ');
  }

  /// Get short address (without ward)
  String get shortAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (province != null && province!.isNotEmpty) parts.add(province!);
    return parts.join(', ');
  }

  /// Copy with
  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? province,
    String? district,
    String? ward,
    String? address,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

/// Auth Response từ backend (register & login)
class AuthResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}
