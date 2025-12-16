import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  /// [POST] /api/orders - Tạo đơn hàng mới
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "shippingAddress": {
  ///     "fullName": "...",
  ///     "phone": "...",
  ///     "province": "...",
  ///     "district": "...",
  ///     "ward": "...",
  ///     "address": "..."
  ///   },
  ///   "paymentMethod": "COD" | "BANK",
  ///   "transactionId": "..." // required nếu BANK,
  ///   "discountCode": "...", // optional
  ///   "notes": "..." // optional
  /// }
  /// ```
  /// 
  /// Response:
  /// - Tạo order từ giỏ hàng hiện tại
  /// - Giảm stock, tăng soldCount cho products
  /// - Xóa giỏ hàng sau khi đặt
  /// - Trả về order với code để tracking
  Future<Map<String, dynamic>> createOrder({
    required ShippingAddress shippingAddress,
    required PaymentMethod paymentMethod,
    String? transactionId,
    String? discountCode,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/orders',
        data: {
          'shippingAddress': shippingAddress.toJson(),
          'paymentMethod': paymentMethod == PaymentMethod.cod ? 'COD' : 'BANK',
          if (transactionId != null) 'transactionId': transactionId,
          if (discountCode != null && discountCode.isNotEmpty)
            'discountCode': discountCode,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        final order = OrderModel.fromJson(response.data['order']);

        return {
          'success': true,
          'order': order,
          'message': response.data['message'] ?? 'Đặt hàng thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Đặt hàng thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [GET] /api/orders - Lấy đơn hàng của người dùng hiện tại
  /// 
  /// Query params:
  /// - status: Filter theo trạng thái (pending, processing, shipped, delivered, cancelled)
  /// - page, limit: Phân trang
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "...",
  ///   "orders": [...],
  ///   "pagination": {
  ///     "page": 1,
  ///     "limit": 10,
  ///     "total": 50,
  ///     "totalPages": 5
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getMyOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.value;
      }

      final response = await _apiClient.dio.get(
        '/api/orders',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final ordersJson = response.data['orders'] as List;
        final orders =
            ordersJson.map((json) => OrderModel.fromJson(json)).toList();

        return {
          'success': true,
          'orders': orders,
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

  /// [GET] /api/orders/:id - Lấy chi tiết đơn hàng theo ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.dio.get('/api/orders/$orderId');

      if (response.data['success'] == true) {
        final order = OrderModel.fromJson(response.data['order']);

        return {
          'success': true,
          'order': order,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không tìm thấy đơn hàng',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [GET] /api/orders/code/:code - Tra cứu đơn hàng theo mã (PUBLIC, không cần auth)
  Future<Map<String, dynamic>> getOrderByCode(String code) async {
    try {
      final response = await _apiClient.dio.get('/api/orders/code/$code');

      if (response.data['success'] == true) {
        final order = OrderModel.fromJson(response.data['order']);

        return {
          'success': true,
          'order': order,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không tìm thấy đơn hàng',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }

  /// [PUT] /api/orders/:id/cancel - Hủy đơn hàng
  /// 
  /// Note: Chỉ cho phép hủy khi status = pending hoặc processing
  /// - Hoàn lại stock và giảm soldCount cho products
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.dio.put('/api/orders/$orderId/cancel');

      if (response.data['success'] == true) {
        final order = OrderModel.fromJson(response.data['order']);

        return {
          'success': true,
          'order': order,
          'message': response.data['message'] ?? 'Hủy đơn hàng thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Hủy đơn hàng thất bại',
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

  /// Helper: Lấy đơn hàng đang chờ (pending)
  Future<Map<String, dynamic>> getPendingOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return await getMyOrders(
      status: OrderStatus.pending,
      page: page,
      limit: limit,
    );
  }

  /// Helper: Lấy đơn hàng đang xử lý (processing)
  Future<Map<String, dynamic>> getProcessingOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return await getMyOrders(
      status: OrderStatus.processing,
      page: page,
      limit: limit,
    );
  }

  /// Helper: Lấy đơn hàng đang giao (shipped)
  Future<Map<String, dynamic>> getShippedOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return await getMyOrders(
      status: OrderStatus.shipped,
      page: page,
      limit: limit,
    );
  }

  /// Helper: Lấy đơn hàng đã giao (delivered)
  Future<Map<String, dynamic>> getDeliveredOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return await getMyOrders(
      status: OrderStatus.delivered,
      page: page,
      limit: limit,
    );
  }

  /// Helper: Lấy đơn hàng đã hủy (cancelled)
  Future<Map<String, dynamic>> getCancelledOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return await getMyOrders(
      status: OrderStatus.cancelled,
      page: page,
      limit: limit,
    );
  }
}
