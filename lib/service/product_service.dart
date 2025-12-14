import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  /// [GET] /api/products - Lấy danh sách sản phẩm với filter
  /// 
  /// Query params:
  /// - category: Filter theo category ID (tự động bao gồm subcategories)
  /// - brand: Filter theo brand ID
  /// - minPrice, maxPrice: Khoảng giá
  /// - search: Tìm kiếm theo name, description
  /// - sort: Sắp xếp (newest, oldest, price-asc, price-desc, name-asc, name-desc, best-seller, rating)
  /// - page, limit: Phân trang
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy danh sách sản phẩm thành công",
  ///   "products": [...],
  ///   "pagination": {
  ///     "page": 1,
  ///     "limit": 10,
  ///     "total": 100,
  ///     "totalPages": 10
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getAllProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;
      if (brand != null) queryParams['brand'] = brand;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _apiClient.dio.get(
        '/api/products',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final productsJson = response.data['products'] as List;
        final products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
          'pagination': response.data['pagination'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Lỗi không xác định',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [GET] /api/products/:slug - Lấy sản phẩm theo slug
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy thông tin sản phẩm thành công",
  ///   "product": {
  ///     "_id": "...",
  ///     "name": "...",
  ///     "slug": "...",
  ///     "sku": "...",
  ///     "description": "...",
  ///     "price": 1000000,
  ///     "originalPrice": 1500000,
  ///     "images": [...],
  ///     "category": { "_id": "...", "name": "...", "slug": "..." },
  ///     "brand": { "_id": "...", "name": "...", "slug": "..." },
  ///     "stock": 50,
  ///     "soldCount": 100,
  ///     "dimensions": { "width": 100, "height": 50, "length": 200 },
  ///     "colors": ["Nâu", "Trắng"],
  ///     "materials": ["Gỗ sồi"],
  ///     "tags": ["sofa", "living-room"],
  ///     "averageRating": 4.5,
  ///     "totalReviews": 20,
  ///     "isFeatured": true
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getProductBySlug(String slug) async {
    try {
      final response = await _apiClient.dio.get('/api/products/$slug');

      if (response.data['success'] == true) {
        final product = ProductModel.fromJson(response.data['product']);

        return {
          'success': true,
          'product': product,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không tìm thấy sản phẩm',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [GET] /api/products/featured - Lấy sản phẩm nổi bật
  /// 
  /// Note: Backend filter isFeatured = true, sort by averageRating, totalReviews, createdAt
  Future<Map<String, dynamic>> getFeaturedProducts({int limit = 8}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/products/featured',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final productsJson = response.data['products'] as List;
        final products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Lỗi không xác định',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [GET] /api/products/related/:productId - Lấy sản phẩm liên quan
  // Future<Map<String, dynamic>> getRelatedProducts(String productId, {int limit = 6}) async {
  //   try {
  //     final response = await _apiClient.dio.get(
  //       '/api/products/related/$productId',
  //       queryParameters: {'limit': limit},
  //     );

  //     if (response.data['success'] == true) {
  //       final productsJson = response.data['products'] as List;
  //       final products = productsJson
  //           .map((json) => ProductModel.fromJson(json))
  //           .toList();

  //       return {
  //         'success': true,
  //         'products': products,
  //       };
  //     }

  //     return {
  //       'success': false,
  //       'message': response.data['message'] ?? 'Lỗi không xác định',
  //     };
  //   } on DioException catch (e) {
  //     return {
  //       'success': false,
  //       'message': e.response?.data['message'] ?? 'Lỗi kết nối',
  //       'error': e.message,
  //     };
  //   }
  // }

  /// [GET] /api/products/new-arrivals - Lấy sản phẩm mới
  /// 
  /// Note: Backend sort by createdAt descending
  Future<Map<String, dynamic>> getNewArrivals({int limit = 8}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/products/new-arrivals',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final productsJson = response.data['products'] as List;
        final products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Lỗi không xác định',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [GET] /api/products/best-sellers - Lấy sản phẩm bán chạy
  /// 
  /// Note: Backend sort by soldCount descending
  Future<Map<String, dynamic>> getBestSellers({int limit = 8}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/products/best-sellers',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final productsJson = response.data['products'] as List;
        final products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Lỗi không xác định',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [GET] /api/products/related/:productId - Lấy sản phẩm liên quan
  /// 
  /// Note: Backend tìm products có cùng category, brand hoặc tags
  Future<Map<String, dynamic>> getRelatedProducts({
    required String productId,
    int limit = 4,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/products/related/$productId',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final productsJson = response.data['products'] as List;
        final products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Lỗi không xác định',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  // ========== ADMIN ROUTES (Require admin role) ==========

  /// [GET] /api/admin/products/:id - Lấy sản phẩm theo ID (ADMIN)
  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await _apiClient.dio.get('/api/admin/products/$productId');

      if (response.data['success'] == true) {
        final product = ProductModel.fromJson(response.data['product']);

        return {
          'success': true,
          'product': product,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không tìm thấy sản phẩm',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [POST] /api/admin/products - Tạo sản phẩm mới (ADMIN)
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "name": "...",
  ///   "sku": "...",
  ///   "description": "...",
  ///   "price": 1000000,
  ///   "originalPrice": 1500000,
  ///   "category": "category_id",
  ///   "brand": "brand_id",
  ///   "stock": 50,
  ///   "images": [...],
  ///   "model3DUrl": "...",
  ///   "dimensions": { "width": 100, "height": 50, "length": 200 },
  ///   "colors": ["Nâu", "Trắng"],
  ///   "materials": ["Gỗ sồi"],
  ///   "tags": ["sofa", "living-room"],
  ///   "isFeatured": true
  /// }
  /// ```
  Future<Map<String, dynamic>> createProduct({
    required String name,
    required String sku,
    required String description,
    required double price,
    double? originalPrice,
    required String category,
    required String brand,
    int stock = 0,
    List<String>? images,
    String? model3DUrl,
    Dimensions? dimensions,
    List<String>? colors,
    List<String>? materials,
    List<String>? tags,
    bool isFeatured = false,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/admin/products',
        data: {
          'name': name,
          'sku': sku,
          'description': description,
          'price': price,
          if (originalPrice != null) 'originalPrice': originalPrice,
          'category': category,
          'brand': brand,
          'stock': stock,
          if (images != null) 'images': images,
          if (model3DUrl != null) 'model3DUrl': model3DUrl,
          if (dimensions != null) 'dimensions': dimensions.toJson(),
          if (colors != null) 'colors': colors,
          if (materials != null) 'materials': materials,
          if (tags != null) 'tags': tags,
          'isFeatured': isFeatured,
        },
      );

      if (response.data['success'] == true) {
        final product = ProductModel.fromJson(response.data['product']);

        return {
          'success': true,
          'product': product,
          'message': response.data['message'] ?? 'Tạo sản phẩm thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Tạo sản phẩm thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [PUT] /api/admin/products/:id - Cập nhật sản phẩm (ADMIN)
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? name,
    String? sku,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    String? brand,
    int? stock,
    List<String>? images,
    String? model3DUrl,
    Dimensions? dimensions,
    List<String>? colors,
    List<String>? materials,
    List<String>? tags,
    bool? isFeatured,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (sku != null) data['sku'] = sku;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (originalPrice != null) data['originalPrice'] = originalPrice;
      if (category != null) data['category'] = category;
      if (brand != null) data['brand'] = brand;
      if (stock != null) data['stock'] = stock;
      if (images != null) data['images'] = images;
      if (model3DUrl != null) data['model3DUrl'] = model3DUrl;
      if (dimensions != null) data['dimensions'] = dimensions.toJson();
      if (colors != null) data['colors'] = colors;
      if (materials != null) data['materials'] = materials;
      if (tags != null) data['tags'] = tags;
      if (isFeatured != null) data['isFeatured'] = isFeatured;

      final response = await _apiClient.dio.put(
        '/api/admin/products/$productId',
        data: data,
      );

      if (response.data['success'] == true) {
        final product = ProductModel.fromJson(response.data['product']);

        return {
          'success': true,
          'product': product,
          'message': response.data['message'] ?? 'Cập nhật sản phẩm thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Cập nhật sản phẩm thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [DELETE] /api/admin/products/:id - Xóa sản phẩm (ADMIN)
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await _apiClient.dio.delete('/api/admin/products/$productId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Xóa sản phẩm thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Xóa sản phẩm thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  // ========== HELPER METHODS ==========

  /// Helper: Tìm kiếm sản phẩm
  Future<Map<String, dynamic>> searchProducts({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    return await getAllProducts(
      search: keyword,
      page: page,
      limit: limit,
    );
  }

  /// Helper: Lọc theo category
  Future<Map<String, dynamic>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    return await getAllProducts(
      category: categoryId,
      page: page,
      limit: limit,
      sort: sort,
    );
  }

  /// Helper: Lọc theo brand
  Future<Map<String, dynamic>> getProductsByBrand({
    required String brandId,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    return await getAllProducts(
      brand: brandId,
      page: page,
      limit: limit,
      sort: sort,
    );
  }

  /// Helper: Lọc theo khoảng giá
  Future<Map<String, dynamic>> getProductsByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int limit = 10,
  }) async {
    return await getAllProducts(
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      limit: limit,
    );
  }
}
