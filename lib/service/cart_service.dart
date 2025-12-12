import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/cart_model.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  /// [GET] /api/cart - Lấy giỏ hàng của người dùng (Protected)
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Lấy giỏ hàng thành công",
  ///   "cart": {
  ///     "_id": "...",
  ///     "user": "...",
  ///     "items": [
  ///       {
  ///         "product": { ... },
  ///         "quantity": 2,
  ///         "price": 1000000
  ///       }
  ///     ],
  ///     "subTotal": 2000000,
  ///     "discount": { "code": "SALE10", "amount": 200000 },
  ///     "totalAmount": 1800000
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _apiClient.dio.get('/api/cart');

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['cart']);

        return {
          'success': true,
          'cart': cart,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không thể lấy giỏ hàng',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [POST] /api/cart/items - Thêm sản phẩm vào giỏ hàng (Protected)
  /// 
  /// Backend expects: productId, quantity (default: 1)
  /// Response: { success, message, cart }
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/cart/items',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['cart']);

        return {
          'success': true,
          'cart': cart,
          'message': response.data['message'] ?? 'Thêm vào giỏ hàng thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Thêm vào giỏ hàng thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [PUT] /api/cart/items/:productId - Cập nhật số lượng sản phẩm (Protected)
  /// 
  /// Backend expects: quantity
  /// Response: { success, message, cart }
  Future<Map<String, dynamic>> updateCartItem({
    required String productId,
    required int quantity,
  }) async {
    try {
      if (quantity < 1) {
        return {
          'success': false,
          'message': 'Số lượng phải lớn hơn hoặc bằng 1',
        };
      }

      final response = await _apiClient.dio.put(
        '/api/cart/items/$productId',
        data: {
          'quantity': quantity,
        },
      );

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['cart']);

        return {
          'success': true,
          'cart': cart,
          'message': response.data['message'] ?? 'Cập nhật giỏ hàng thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Cập nhật thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [DELETE] /api/cart/items/:productId - Xóa sản phẩm khỏi giỏ hàng (Protected)
  /// 
  /// Response: { success, message, cart }
  Future<Map<String, dynamic>> removeCartItem({
    required String productId,
  }) async {
    try {
      final response = await _apiClient.dio.delete(
        '/api/cart/items/$productId',
      );

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['cart']);

        return {
          'success': true,
          'cart': cart,
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
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [DELETE] /api/cart - Xóa toàn bộ giỏ hàng (Protected)
  /// 
  /// Response: { success, message, cart }
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await _apiClient.dio.delete('/api/cart');

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['cart']);

        return {
          'success': true,
          'cart': cart,
          'message': response.data['message'] ?? 'Xóa giỏ hàng thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Xóa giỏ hàng thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [POST] /api/cart/discount - Áp dụng mã giảm giá (Protected)
  /// 
  /// Backend expects: code
  /// Response format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Áp dụng mã giảm giá thành công",
  ///   "cart": { ... },
  ///   "discount": {
  ///     "code": "SALE10",
  ///     "amount": 200000,
  ///     "type": "percentage",
  ///     "value": 10
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> applyDiscount({
    required String code,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/cart/discount',
        data: {
          'code': code.toUpperCase(),
        },
      );

      if (response.data['success'] == true) {
        final discountResponse = DiscountApplyResponse.fromJson(response.data);

        return {
          'success': true,
          'cart': discountResponse.cart,
          'discount': discountResponse.discount,
          'message': discountResponse.message,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Áp dụng mã giảm giá thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// [DELETE] /api/cart/discount - Gỡ mã giảm giá (Protected)
  /// 
  /// Response: { success, message, cart }
  Future<Map<String, dynamic>> removeDiscount() async {
    try {
      final response = await _apiClient.dio.delete('/api/cart/discount');

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['cart']);

        return {
          'success': true,
          'cart': cart,
          'message': response.data['message'] ?? 'Gỡ mã giảm giá thành công',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gỡ mã giảm giá thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.response?.data['error'] ?? e.message,
      };
    }
  }

  /// Helper: Tăng quantity của item (wrapper cho updateCartItem)
  Future<Map<String, dynamic>> incrementItem({
    required String productId,
    required int currentQuantity,
  }) async {
    return await updateCartItem(
      productId: productId,
      quantity: currentQuantity + 1,
    );
  }

  /// Helper: Giảm quantity của item (wrapper cho updateCartItem)
  Future<Map<String, dynamic>> decrementItem({
    required String productId,
    required int currentQuantity,
  }) async {
    if (currentQuantity <= 1) {
      // Nếu quantity = 1, xóa item thay vì giảm
      return await removeCartItem(productId: productId);
    }
    
    return await updateCartItem(
      productId: productId,
      quantity: currentQuantity - 1,
    );
  }
}
