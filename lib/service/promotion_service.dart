import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/promotion_model.dart';

class PromotionService {
  final ApiClient _apiClient;

  PromotionService(this._apiClient);

  /// [GET] /api/promotions - Lấy tất cả promotion đang hoạt động (PUBLIC)
  /// 
  /// Note: Backend tự động filter:
  /// - isActive = true
  /// - startDate <= now
  /// - endDate >= now
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy danh sách khuyến mãi thành công",
  ///   "promotions": [
  ///     {
  ///       "_id": "...",
  ///       "code": "SUMMER2023",
  ///       "description": "Giảm 20% cho đơn hàng từ 1 triệu",
  ///       "discountType": "percentage",
  ///       "discountValue": 20,
  ///       "startDate": "2023-06-01",
  ///       "endDate": "2023-08-31",
  ///       "minSpend": 1000000,
  ///       "isActive": true
  ///     }
  ///   ]
  /// }
  /// ```
  Future<Map<String, dynamic>> getAllPromotions() async {
    try {
      final response = await _apiClient.dio.get('/api/promotions');

      if (response.data['success'] == true) {
        final promotionsJson = response.data['promotions'] as List;
        final promotions = promotionsJson
            .map((json) => PromotionModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'promotions': promotions,
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

  /// [POST] /api/promotions/validate - Kiểm tra và validate mã khuyến mãi (PUBLIC)
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "code": "SUMMER2023",
  ///   "orderAmount": 1500000  // optional
  /// }
  /// ```
  /// 
  /// Response khi valid:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Mã khuyến mãi hợp lệ",
  ///   "valid": true,
  ///   "promotion": {
  ///     "code": "SUMMER2023",
  ///     "description": "...",
  ///     "discountType": "percentage",
  ///     "discountValue": 20,
  ///     "minSpend": 1000000,
  ///     "startDate": "...",
  ///     "endDate": "..."
  ///   },
  ///   "discountAmount": 300000  // Nếu có orderAmount
  /// }
  /// ```
  /// 
  /// Response khi invalid:
  /// ```json
  /// {
  ///   "success": false,
  ///   "message": "Mã khuyến mãi đã hết hạn",
  ///   "valid": false
  /// }
  /// ```
  Future<Map<String, dynamic>> validatePromotionCode({
    required String code,
    double? orderAmount,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/promotions/validate',
        data: {
          'code': code.toUpperCase(),
          if (orderAmount != null) 'orderAmount': orderAmount,
        },
      );

      // Backend có thể trả về success: false khi invalid
      final validationResult = PromotionValidationResult.fromJson(response.data);

      return {
        'success': response.data['success'] ?? false,
        'valid': validationResult.valid,
        'message': validationResult.message,
        'promotion': validationResult.promotion,
        'discountAmount': validationResult.discountAmount,
        'minSpend': validationResult.minSpend,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'valid': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  // ========== ADMIN ROUTES (Require admin role) ==========

  /// [GET] /api/admin/promotions - Lấy tất cả promotions (ADMIN)
  /// 
  /// Query params:
  /// - page, limit: Phân trang
  /// - isActive: Filter theo trạng thái (true/false)
  /// - search: Tìm kiếm theo code, description
  /// - sortBy: Sắp xếp (mặc định: -createdAt)
  /// 
  /// Response:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "...",
  ///   "promotions": [...],
  ///   "pagination": { ... },
  ///   "stats": {
  ///     "activeCount": 5,
  ///     "totalCount": 10
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getAllPromotionsAdmin({
    int page = 1,
    int limit = 20,
    bool? isActive,
    String? search,
    String sortBy = '-createdAt',
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
      };

      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.dio.get(
        '/api/admin/promotions',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final promotionsJson = response.data['promotions'] as List;
        final promotions = promotionsJson
            .map((json) => PromotionModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'promotions': promotions,
          'pagination': response.data['pagination'],
          'stats': response.data['stats'] != null
              ? PromotionStats.fromJson(response.data['stats'])
              : null,
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

  /// [GET] /api/admin/promotions/:id - Lấy promotion theo ID (ADMIN)
  Future<Map<String, dynamic>> getPromotionById(String promotionId) async {
    try {
      final response =
          await _apiClient.dio.get('/api/admin/promotions/$promotionId');

      if (response.data['success'] == true) {
        final promotion = PromotionModel.fromJson(response.data['promotion']);

        return {
          'success': true,
          'promotion': promotion,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không tìm thấy khuyến mãi',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [POST] /api/admin/promotions - Tạo promotion mới (ADMIN)
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "code": "SUMMER2023",
  ///   "description": "Giảm 20% cho đơn hàng từ 1 triệu",
  ///   "discountType": "percentage",  // "percentage" hoặc "fixed"
  ///   "discountValue": 20,
  ///   "startDate": "2023-06-01",
  ///   "endDate": "2023-08-31",
  ///   "minSpend": 1000000,  // optional, default 0
  ///   "isActive": true  // optional, default true
  /// }
  /// ```
  /// 
  /// Validations:
  /// - code: Bắt buộc, unique, tự động uppercase
  /// - discountType: "percentage" hoặc "fixed"
  /// - discountValue: Nếu percentage thì 0-100
  /// - startDate < endDate
  Future<Map<String, dynamic>> createPromotion({
    required String code,
    required String description,
    required DiscountType discountType,
    required double discountValue,
    required DateTime startDate,
    required DateTime endDate,
    double minSpend = 0,
    bool isActive = true,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/admin/promotions',
        data: {
          'code': code.toUpperCase(),
          'description': description,
          'discountType':
              discountType == DiscountType.fixed ? 'fixed' : 'percentage',
          'discountValue': discountValue,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'minSpend': minSpend,
          'isActive': isActive,
        },
      );

      if (response.data['success'] == true) {
        final promotion = PromotionModel.fromJson(response.data['promotion']);

        return {
          'success': true,
          'promotion': promotion,
          'message': response.data['message'] ?? 'Tạo khuyến mãi thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Tạo khuyến mãi thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [PUT] /api/admin/promotions/:id - Cập nhật promotion (ADMIN)
  Future<Map<String, dynamic>> updatePromotion({
    required String promotionId,
    String? code,
    String? description,
    DiscountType? discountType,
    double? discountValue,
    DateTime? startDate,
    DateTime? endDate,
    double? minSpend,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (code != null) data['code'] = code.toUpperCase();
      if (description != null) data['description'] = description;
      if (discountType != null) {
        data['discountType'] =
            discountType == DiscountType.fixed ? 'fixed' : 'percentage';
      }
      if (discountValue != null) data['discountValue'] = discountValue;
      if (startDate != null) data['startDate'] = startDate.toIso8601String();
      if (endDate != null) data['endDate'] = endDate.toIso8601String();
      if (minSpend != null) data['minSpend'] = minSpend;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _apiClient.dio.put(
        '/api/admin/promotions/$promotionId',
        data: data,
      );

      if (response.data['success'] == true) {
        final promotion = PromotionModel.fromJson(response.data['promotion']);

        return {
          'success': true,
          'promotion': promotion,
          'message': response.data['message'] ?? 'Cập nhật khuyến mãi thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Cập nhật khuyến mãi thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [DELETE] /api/admin/promotions/:id - Xóa promotion (ADMIN)
  Future<Map<String, dynamic>> deletePromotion(String promotionId) async {
    try {
      final response =
          await _apiClient.dio.delete('/api/admin/promotions/$promotionId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Xóa khuyến mãi thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Xóa khuyến mãi thất bại',
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

  /// Helper: Lấy promotions đang active
  Future<Map<String, dynamic>> getActivePromotions() async {
    return await getAllPromotions();
  }

  /// Helper: Apply promotion code cho order amount
  Future<Map<String, dynamic>> applyPromotionCode({
    required String code,
    required double orderAmount,
  }) async {
    final result = await validatePromotionCode(
      code: code,
      orderAmount: orderAmount,
    );

    if (result['valid'] == true) {
      return {
        'success': true,
        'code': code,
        'discountAmount': result['discountAmount'],
        'promotion': result['promotion'],
      };
    } else {
      return {
        'success': false,
        'message': result['message'],
      };
    }
  }
}
