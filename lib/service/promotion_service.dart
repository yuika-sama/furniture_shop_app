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
