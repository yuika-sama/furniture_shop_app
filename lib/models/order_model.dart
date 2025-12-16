import 'product_model.dart';
import 'user_model.dart';
import 'cart_model.dart';

/// Order Model
class OrderModel {
  final String id;
  final String? userId;
  final UserModel? user; // Populated
  final String code;
  final List<OrderItem> items;
  final ShippingAddress shippingAddress;
  final PaymentInfo payment;
  final OrderStatus status;
  final double subTotal;
  final double shippingFee;
  final DiscountInfo discount;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    this.userId,
    this.user,
    required this.code,
    required this.items,
    required this.shippingAddress,
    required this.payment,
    required this.status,
    required this.subTotal,
    required this.shippingFee,
    required this.discount,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['user'] is String ? json['user'] : null,
      user: json['user'] is Map ? UserModel.fromJson(json['user']) : null,
      code: json['code'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      payment: PaymentInfo.fromJson(json['payment'] ?? {}),
      status: _parseOrderStatus(json['status']),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      discount: DiscountInfo.fromJson(json['discount'] ?? {}),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      notes: json['notes'],
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
      'user': userId,
      'code': code,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'payment': payment.toJson(),
      'status': status.value,
      'subTotal': subTotal,
      'shippingFee': shippingFee,
      'discount': discount.toJson(),
      'totalAmount': totalAmount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  // Getters
  bool get isPending => status == OrderStatus.pending;
  bool get isProcessing => status == OrderStatus.processing;
  bool get isShipped => status == OrderStatus.shipped;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.processing;
  
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipped:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get paymentMethodText {
    return payment.method == PaymentMethod.cod ? 'COD' : 'Chuyển khoản';
  }

  String get paymentStatusText {
    switch (payment.status) {
      case PaymentStatus.pending:
        return 'Chờ thanh toán';
      case PaymentStatus.completed:
        return 'Đã thanh toán';
      case PaymentStatus.failed:
        return 'Thanh toán thất bại';
    }
  }
}

/// Order Item - Sản phẩm trong đơn hàng
class OrderItem {
  final String productId;
  final ProductModel? product; 
  final String name;
  final int quantity;
  final double price;
  final String? image;

  OrderItem({
    required this.productId,
    this.product,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product'] is String
          ? json['product']
          : json['product']?['_id'] ?? '',
      product: json['product'] is Map
          ? ProductModel.fromJson(json['product'])
          : null,
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'image': image,
    };
  }

  double get itemTotal => price * quantity;
}

/// Shipping Address - Địa chỉ giao hàng
class ShippingAddress {
  final String fullName;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String address;

  ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.address,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'address': address,
    };
  }

  String get fullAddress {
    return '$address, $ward, $district, $province';
  }
}

/// Payment Info - Thông tin thanh toán
class PaymentInfo {
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;

  PaymentInfo({
    required this.method,
    required this.status,
    this.transactionId,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: json['method'] == 'BANK' ? PaymentMethod.bank : PaymentMethod.cod,
      status: _parsePaymentStatus(json['status']),
      transactionId: json['transactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method == PaymentMethod.cod ? 'COD' : 'BANK',
      'status': status.value,
      'transactionId': transactionId,
    };
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}


/// Order Status Enum
enum OrderStatus {
  pending('pending'),
  processing('processing'),
  shipped('shipped'),
  delivered('delivered'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);
}

/// Payment Method Enum
enum PaymentMethod {
  cod,
  bank;
}

/// Payment Status Enum
enum PaymentStatus {
  pending('pending'),
  completed('completed'),
  failed('failed');

  final String value;
  const PaymentStatus(this.value);
}

/// Order Statistics (for admin)
class OrderStats {
  final double totalRevenue;
  final int totalOrders;
  final List<RevenueByStatus> revenueByStatus;
  final List<OrderCountByStatus> orderCountByStatus;
  final List<BestSellingProduct> bestSellingProducts;

  OrderStats({
    required this.totalRevenue,
    required this.totalOrders,
    this.revenueByStatus = const [],
    this.orderCountByStatus = const [],
    this.bestSellingProducts = const [],
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      revenueByStatus: (json['revenueByStatus'] as List?)
              ?.map((item) => RevenueByStatus.fromJson(item))
              .toList() ??
          [],
      orderCountByStatus: (json['orderCountByStatus'] as List?)
              ?.map((item) => OrderCountByStatus.fromJson(item))
              .toList() ??
          [],
      bestSellingProducts: (json['bestSellingProducts'] as List?)
              ?.map((item) => BestSellingProduct.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class RevenueByStatus {
  final String status;
  final double total;
  final int count;

  RevenueByStatus({
    required this.status,
    required this.total,
    required this.count,
  });

  factory RevenueByStatus.fromJson(Map<String, dynamic> json) {
    return RevenueByStatus(
      status: json['_id'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class OrderCountByStatus {
  final String status;
  final int count;

  OrderCountByStatus({
    required this.status,
    required this.count,
  });

  factory OrderCountByStatus.fromJson(Map<String, dynamic> json) {
    return OrderCountByStatus(
      status: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class BestSellingProduct {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final int totalSold;
  final double revenue;

  BestSellingProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    required this.totalSold,
    required this.revenue,
  });

  factory BestSellingProduct.fromJson(Map<String, dynamic> json) {
    return BestSellingProduct(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      totalSold: json['totalSold'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}
