import 'product_model.dart';

/// Wishlist Model - Danh sách yêu thích của user
class WishlistModel {
  final String id;
  final String user;
  final List<ProductModel> products;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishlistModel({
    required this.id,
    required this.user,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['_id'] ?? '',
      user: json['user'] is String ? json['user'] : json['user']?['_id'] ?? '',
      products: json['products'] != null
          ? List<ProductModel>.from(
              json['products'].map((x) => ProductModel.fromJson(x)))
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'products': products.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Getters
  int get count => products.length;
  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;

  /// Check if product is in wishlist
  bool containsProduct(String productId) {
    return products.any((p) => p.id == productId);
  }

  /// Get product IDs
  List<String> get productIds => products.map((p) => p.id).toList();

  /// Total value of wishlist
  double get totalValue {
    return products.fold(0.0, (sum, product) => sum + product.finalPrice);
  }

  /// Total original value (before discount)
  double get totalOriginalValue {
    return products.fold(0.0, (sum, product) => sum + product.price);
  }

  /// Total savings
  double get totalSavings => totalOriginalValue - totalValue;

  /// Average rating of products
  double get averageRating {
    if (products.isEmpty) return 0.0;
    final totalRating = products.fold(0.0, (sum, p) => sum + p.averageRating);
    return totalRating / products.length;
  }

  /// In-stock products count
  int get inStockCount => products.where((p) => p.inStock).length;

  /// Out-of-stock products count
  int get outOfStockCount => products.where((p) => !p.inStock).length;

  /// Products on sale
  List<ProductModel> get productsOnSale {
    return products.where((p) => p.hasDiscount).toList();
  }

  /// Products in stock
  List<ProductModel> get productsInStock {
    return products.where((p) => p.inStock).toList();
  }

  /// Copy with
  WishlistModel copyWith({
    String? id,
    String? user,
    List<ProductModel>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      user: user ?? this.user,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Wishlist response
class WishlistResponse {
  final WishlistModel wishlist;
  final int count;

  WishlistResponse({
    required this.wishlist,
    required this.count,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      wishlist: WishlistModel.fromJson(json['wishlist']),
      count: json['count'] ?? 0,
    );
  }

  bool get isEmpty => count == 0;
  bool get isNotEmpty => count > 0;
}
