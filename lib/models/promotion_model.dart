/// Promotion Model - Map với Promotion schema trong backend
class PromotionModel {
  final String id;
  final String code;
  final String description;
  final DiscountType discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final double minSpend;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PromotionModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.minSpend,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discountType'] == 'fixed'
          ? DiscountType.fixed
          : DiscountType.percentage,
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      minSpend: (json['minSpend'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'description': description,
      'discountType': discountType == DiscountType.fixed ? 'fixed' : 'percentage',
      'discountValue': discountValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'minSpend': minSpend,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Getters
  /// Kiểm tra promotion còn hiệu lực không
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Kiểm tra promotion đã hết hạn chưa
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Kiểm tra promotion chưa bắt đầu
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  /// Tính discount amount dựa trên order amount
  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;
    if (orderAmount < minSpend) return 0;

    double discount = 0;
    if (discountType == DiscountType.percentage) {
      discount = (orderAmount * discountValue) / 100;
    } else {
      discount = discountValue;
    }

    // Discount không được vượt quá order amount
    if (discount > orderAmount) {
      discount = orderAmount;
    }

    return discount;
  }

  /// Text hiển thị giá trị giảm
  String get discountText {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return '${discountValue.toStringAsFixed(0)}đ';
    }
  }

  /// Text hiển thị min spend
  String get minSpendText {
    if (minSpend == 0) return 'Không giới hạn';
    return 'Đơn tối thiểu ${minSpend.toStringAsFixed(0)}đ';
  }

  /// Text hiển thị thời gian
  String get dateRangeText {
    final startStr = '${startDate.day}/${startDate.month}/${startDate.year}';
    final endStr = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$startStr - $endStr';
  }

  /// Số ngày còn lại
  int get daysRemaining {
    if (isExpired) return 0;
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  /// Status text
  String get statusText {
    if (isExpired) return 'Đã hết hạn';
    if (isUpcoming) return 'Sắp diễn ra';
    if (isValid) return 'Đang áp dụng';
    return 'Không hoạt động';
  }
}

/// Discount Type Enum
enum DiscountType {
  percentage, // Giảm theo phần trăm
  fixed, // Giảm số tiền cố định
}

/// Validation Result - Kết quả validate promotion code
class PromotionValidationResult {
  final bool valid;
  final String message;
  final PromotionDetails? promotion;
  final double discountAmount;
  final double? minSpend;

  PromotionValidationResult({
    required this.valid,
    required this.message,
    this.promotion,
    this.discountAmount = 0,
    this.minSpend,
  });

  factory PromotionValidationResult.fromJson(Map<String, dynamic> json) {
    return PromotionValidationResult(
      valid: json['valid'] ?? false,
      message: json['message'] ?? '',
      promotion: json['promotion'] != null
          ? PromotionDetails.fromJson(json['promotion'])
          : null,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      minSpend: json['minSpend']?.toDouble(),
    );
  }
}

/// Promotion Details - Chi tiết promotion khi validate
class PromotionDetails {
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double minSpend;
  final DateTime startDate;
  final DateTime endDate;

  PromotionDetails({
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minSpend,
    required this.startDate,
    required this.endDate,
  });

  factory PromotionDetails.fromJson(Map<String, dynamic> json) {
    return PromotionDetails(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discountType'] ?? 'percentage',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minSpend: (json['minSpend'] ?? 0).toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
    );
  }

  String get discountText {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return '${discountValue.toStringAsFixed(0)}đ';
    }
  }
}

/// Promotion Stats - Thống kê cho admin
class PromotionStats {
  final int activeCount;
  final int totalCount;

  PromotionStats({
    required this.activeCount,
    required this.totalCount,
  });

  factory PromotionStats.fromJson(Map<String, dynamic> json) {
    return PromotionStats(
      activeCount: json['activeCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  int get inactiveCount => totalCount - activeCount;
}
