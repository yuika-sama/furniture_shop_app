import 'category_model.dart';
import 'brand_model.dart';

/// Product Model - Map với Product schema trong backend
class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String sku;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String? model3DUrl;
  
  // Category & Brand (có thể là ID hoặc populated object)
  final String categoryId;
  final CategoryModel? category;
  final String? brandId;
  final BrandModel? brand;
  
  // Stock & Sales
  final int stock;
  final int soldCount;
  
  // Specifications
  final Dimensions? dimensions;
  final List<String> colors;
  final List<String> materials;
  final List<String> tags;
  
  // Reviews
  final double averageRating;
  final int totalReviews;
  
  // Featured
  final bool isFeatured;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.sku,
    required this.description,
    required this.price,
    this.originalPrice,
    this.images = const [],
    this.model3DUrl,
    required this.categoryId,
    this.category,
    this.brandId,
    this.brand,
    this.stock = 0,
    this.soldCount = 0,
    this.dimensions,
    this.colors = const [],
    this.materials = const [],
    this.tags = const [],
    this.averageRating = 0,
    this.totalReviews = 0,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      sku: json['sku'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice'] != null 
          ? (json['originalPrice']).toDouble() 
          : null,
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
      model3DUrl: json['model3DUrl'],
      categoryId: json['category'] is String 
          ? json['category'] 
          : json['category']?['_id'] ?? '',
      category: json['category'] is Map 
          ? CategoryModel.fromJson(json['category']) 
          : (json['category'] is String && json['category'] != null)
              ? CategoryModel(
                  id: json['category'],
                  name: json['category'],
                  slug: json['category'].toString().toLowerCase().replaceAll(' ', '-'),
                )
              : null,
      brandId: json['brand'] is String 
          ? json['brand'] 
          : json['brand']?['_id'],
      brand: json['brand'] is Map 
          ? BrandModel.fromJson(json['brand']) 
          : (json['brand'] is String && json['brand'] != null)
              ? BrandModel(
                  id: json['brand'],
                  name: json['brand'],
                  slug: json['brand'].toString().toLowerCase().replaceAll(' ', '-'),
                )
              : null,
      stock: json['stock'] ?? 0,
      soldCount: json['soldCount'] ?? 0,
      dimensions: json['dimensions'] != null 
          ? Dimensions.fromJson(json['dimensions']) 
          : null,
      colors: json['colors'] != null 
          ? List<String>.from(json['colors']) 
          : [],
      materials: json['materials'] != null 
          ? List<String>.from(json['materials']) 
          : [],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  } 
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'sku': sku,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'model3DUrl': model3DUrl,
      'category': categoryId,
      'brand': brandId,
      'stock': stock,
      'soldCount': soldCount,
      'dimensions': dimensions?.toJson(),
      'colors': colors,
      'materials': materials,
      'tags': tags,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Getters
  /// Có giảm giá không (originalPrice > price)
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// Phần trăm giảm giá
  int get discountPercent {
    if (!hasDiscount) return 0;
    return ((1 - (price / originalPrice!)) * 100).round();
  }

  /// Giá tiết kiệm được
  double get savedAmount {
    if (!hasDiscount) return 0;
    return originalPrice! - price;
  }

  /// Còn hàng không
  bool get inStock => stock > 0;

  /// Sắp hết hàng (< 10)
  bool get lowStock => stock > 0 && stock < 10;

  /// Hết hàng
  bool get outOfStock => stock <= 0;

  /// Lấy ảnh đầu tiên
  String get primaryImage {
    if (images.isEmpty) return '';
    return images.first;
  }

  /// Tên category
  String get categoryName => category?.name ?? '';

  /// Tên brand
  String get brandName => brand?.name ?? '';

  /// Rating text (1.5 -> "1.5 ⭐")
  String get ratingText {
    if (averageRating == 0) return 'Chưa có đánh giá';
    return '${averageRating.toStringAsFixed(1)} ⭐';
  }

  /// Reviews text (10 -> "10 đánh giá")
  String get reviewsText {
    if (totalReviews == 0) return 'Chưa có đánh giá';
    return '$totalReviews đánh giá';
  }

  /// Giá cuối cùng (sau giảm giá)
  double get finalPrice => price;

  /// Get full image URL
  String getFullImageUrl(String baseUrl, {int index = 0}) {
    if (images.isEmpty) {
      return 'https://via.placeholder.com/400x400?text=No+Image';
    }
    final image = index < images.length ? images[index] : images.first;
    if (image.startsWith('http')) return image;
    return '$baseUrl/$image';
  }
}

/// Dimensions Model
class Dimensions {
  final double? width;
  final double? height;
  final double? length;

  Dimensions({
    this.width,
    this.height,
    this.length,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: _parseDoubleValue(json['width']),
      height: _parseDoubleValue(json['height']),
      length: _parseDoubleValue(json['length']),
    );
  }

  /// Parse value that can be number, string, or range like "1140-1220"
  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    
    if (value is num) {
      return value.toDouble();
    }
    
    if (value is String) {
      // Handle range like "1140-1220" - take the first value
      if (value.contains('-')) {
        final parts = value.split('-');
        if (parts.isNotEmpty) {
          return double.tryParse(parts[0].trim());
        }
      }
      return double.tryParse(value);
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'length': length,
    };
  }

  String get dimensionText {
    if (width == null && height == null && length == null) {
      return 'Chưa có thông tin';
    }
    
    final w = width?.toInt() ?? 0;
    final h = height?.toInt() ?? 0;
    final l = length?.toInt() ?? 0;
    
    return 'R: $w x C: $h x D: $l mm';
  }
}
