import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  /// [GET] /api/categories - Lấy tất cả danh mục
  /// 
  /// Query params:
  /// - page, limit: Phân trang
  /// - search: Tìm kiếm theo tên
  /// - parent: Filter theo parentCategory (null = lấy root categories)
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy danh sách danh mục thành công",
  ///   "categories": [...],
  ///   "pagination": { // nếu có page & limit
  ///     "page": 1,
  ///     "limit": 20,
  ///     "total": 50,
  ///     "totalPages": 3
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getAllCategories({
    int? page,
    int? limit,
    String? search,
    String? parent, // 'null' để lấy root categories
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (parent != null) queryParams['parent'] = parent;

      final response = await _apiClient.dio.get(
        '/api/categories',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final categoriesJson = response.data['categories'] as List;
        final categories = categoriesJson
            .map((json) => CategoryModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'categories': categories,
          'pagination': response.data['pagination'], // có thể null
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

  /// [GET] /api/categories/tree - Lấy cấu trúc cây danh mục
  /// 
  /// Trả về categories với children nested
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy cấu trúc danh mục thành công",
  ///   "tree": [
  ///     {
  ///       "_id": "...",
  ///       "name": "Furniture",
  ///       "slug": "furniture",
  ///       "children": [
  ///         {
  ///           "_id": "...",
  ///           "name": "Living Room",
  ///           "slug": "living-room",
  ///           "parentCategory": "...",
  ///           "children": []
  ///         }
  ///       ]
  ///     }
  ///   ]
  /// }
  /// ```
  Future<Map<String, dynamic>> getCategoryTree() async {
    try {
      final response = await _apiClient.dio.get('/api/categories/tree');

      if (response.data['success'] == true) {
        final treeJson = response.data['tree'] as List;
        final categories = treeJson
            .map((json) => CategoryModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'categories': categories,
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

  /// [GET] /api/categories/:slug - Lấy danh mục theo slug
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy thông tin danh mục thành công",
  ///   "category": {
  ///     "_id": "...",
  ///     "name": "Living Room",
  ///     "slug": "living-room",
  ///     "description": "...",
  ///     "image": "...",
  ///     "parentCategory": { ... },
  ///     "productCount": 10
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getCategoryBySlug(String slug) async {
    try {
      final response = await _apiClient.dio.get('/api/categories/$slug');

      if (response.data['success'] == true) {
        final category = CategoryModel.fromJson(response.data['category']);

        return {
          'success': true,
          'category': category,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không tìm thấy danh mục',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// Helper: Lấy tất cả root categories (không có parent)
  Future<Map<String, dynamic>> getRootCategories({
    int? page,
    int? limit,
  }) async {
    return await getAllCategories(
      page: page,
      limit: limit,
      parent: 'null', // Backend filter parentCategory = null
    );
  }

  /// Helper: Lấy subcategories của một parent
  Future<Map<String, dynamic>> getSubcategories({
    required String parentId,
    int? page,
    int? limit,
  }) async {
    return await getAllCategories(
      page: page,
      limit: limit,
      parent: parentId,
    );
  }

  /// Helper: Lấy categories phổ biến (có nhiều sản phẩm nhất)
  /// Note: Backend không có endpoint riêng, cần sort ở client
  Future<Map<String, dynamic>> getPopularCategories({
    int limit = 10,
  }) async {
    final result = await getAllCategories();
    
    if (result['success'] == true) {
      final categories = result['categories'] as List<CategoryModel>;
      
      // Sort by productCount descending
      categories.sort((a, b) => b.productCount.compareTo(a.productCount));
      
      return {
        'success': true,
        'categories': categories.take(limit).toList(),
      };
    }
    
    return result;
  }
}
