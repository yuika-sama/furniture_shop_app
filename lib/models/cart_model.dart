import 'product_model.dart';

/// Cart Item Model
class CartItem {
  final String productId;
  final ProductModel? product; 
  final int quantity;
  final double price;

  CartItem({
    required this.productId,
    this.product,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product'] is String 
          ? json['product'] 
          : json['product']?['_id'] ?? '',
      product: json['product'] is Map 
          ? ProductModel.fromJson(json['product']) 
          : null,
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  /// Tổng tiền của item này
  double get total => price * quantity;

  /// Copy with new values
  CartItem copyWith({
    String? productId,
    ProductModel? product,
    int? quantity,
    double? price,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

/// Discount Info
class DiscountInfo {
  final String? code;
  final double amount;

  DiscountInfo({
    this.code,
    this.amount = 0,
  });

  factory DiscountInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DiscountInfo(code: null, amount: 0);
    }
    return DiscountInfo(
      code: json['code'],
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'amount': amount,
    };
  }

  bool get hasDiscount => code != null && amount > 0;
}

/// Cart Model
class CartModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subTotal;
  final DiscountInfo discount;
  final double totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    this.subTotal = 0,
    DiscountInfo? discount,
    this.totalAmount = 0,
    this.createdAt,
    this.updatedAt,
  }) : discount = discount ?? DiscountInfo();

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : [],
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      discount: DiscountInfo.fromJson(json['discount']),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
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
      'user': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subTotal': subTotal,
      'discount': discount.toJson(),
      'totalAmount': totalAmount,
    };
  }

  /// Số lượng items trong giỏ
  int get itemCount => items.length;

  /// Tổng số sản phẩm (tính cả quantity)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Kiểm tra giỏ hàng có trống không
  bool get isEmpty => items.isEmpty;

  /// Kiểm tra giỏ hàng có sản phẩm không
  bool get isNotEmpty => items.isNotEmpty;

  /// Tiết kiệm được bao nhiêu (discount amount)
  double get savings => discount.amount;

  /// Giá cuối cùng phải trả
  double get finalPrice => totalAmount;

  /// Tìm item theo productId
  CartItem? findItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra product có trong giỏ không
  bool hasProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Lấy quantity của product
  int getQuantity(String productId) {
    final item = findItem(productId);
    return item?.quantity ?? 0;
  }
}

/// Discount Apply Response
class DiscountApplyResponse {
  final bool success;
  final String message;
  final CartModel? cart;
  final DiscountDetails? discount;

  DiscountApplyResponse({
    required this.success,
    required this.message,
    this.cart,
    this.discount,
  });

  factory DiscountApplyResponse.fromJson(Map<String, dynamic> json) {
    return DiscountApplyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      cart: json['cart'] != null ? CartModel.fromJson(json['cart']) : null,
      discount: json['discount'] != null 
          ? DiscountDetails.fromJson(json['discount']) 
          : null,
    );
  }
}

/// Discount Details
class DiscountDetails {
  final String code;
  final double amount;
  final String type; 
  final double value;

  DiscountDetails({
    required this.code,
    required this.amount,
    required this.type,
    required this.value,
  });

  factory DiscountDetails.fromJson(Map<String, dynamic> json) {
    return DiscountDetails(
      code: json['code'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'fixed',
      value: (json['value'] ?? 0).toDouble(),
    );
  }

  /// Mô tả giảm giá
  String get description {
    if (type == 'percentage') {
      return 'Giảm ${value.toInt()}%';
    } else {
      return 'Giảm ${amount.toStringAsFixed(0)}đ';
    }
  }
}
