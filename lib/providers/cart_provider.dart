import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../service/api_client.dart';
import '../service/cart_service.dart';
import 'auth_provider.dart';

/// Cart State Provider
class CartProvider with ChangeNotifier {
  final CartService _cartService;
  final AuthProvider? _authProvider;

  CartProvider({
    CartService? cartService,
    AuthProvider? authProvider,
  })  : _cartService = cartService ?? CartService(ApiClient()),
        _authProvider = authProvider;
  
  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Computed properties
  int get itemCount => _cart?.itemCount ?? 0;
  int get totalItems => _cart?.totalItems ?? 0;
  double get subTotal => _cart?.subTotal ?? 0;
  double get totalAmount => _cart?.totalAmount ?? 0;
  double get savings => _cart?.savings ?? 0;
  bool get isEmpty => _cart?.isEmpty ?? true;
  bool get isNotEmpty => _cart?.isNotEmpty ?? false;
  bool get hasDiscount => _cart?.discount.hasDiscount ?? false;
  String? get discountCode => _cart?.discount.code;

  /// Load giỏ hàng từ server
  Future<bool> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _cartService.getCart();

    _isLoading = false;

    if (result['success'] == true) {
      _cart = result['cart'] as CartModel;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _cartService.addToCart(
      productId: productId,
      quantity: quantity,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _cart = result['cart'] as CartModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result;
  }

  /// Cập nhật số lượng sản phẩm
  Future<Map<String, dynamic>> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _cartService.updateCartItem(
      productId: productId,
      quantity: quantity,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _cart = result['cart'] as CartModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result;
  }

  /// Tăng số lượng
  Future<Map<String, dynamic>> incrementItem(String productId) async {
    final currentQuantity = _cart?.getQuantity(productId) ?? 0;
    if (currentQuantity == 0) return {'success': false};

    return await updateQuantity(
      productId: productId,
      quantity: currentQuantity + 1,
    );
  }

  /// Giảm số lượng
  Future<Map<String, dynamic>> decrementItem(String productId) async {
    final currentQuantity = _cart?.getQuantity(productId) ?? 0;
    if (currentQuantity <= 1) {
      return await removeItem(productId);
    }

    return await updateQuantity(
      productId: productId,
      quantity: currentQuantity - 1,
    );
  }

  /// Xóa sản phẩm
  Future<Map<String, dynamic>> removeItem(String productId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _cartService.removeCartItem(
      productId: productId,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _cart = result['cart'] as CartModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result;
  }

  /// Xóa toàn bộ giỏ hàng
  Future<Map<String, dynamic>> clearCart() async {
    _isLoading = true;
    notifyListeners();

    final result = await _cartService.clearCart();

    _isLoading = false;

    if (result['success'] == true) {
      _cart = result['cart'] as CartModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result;
  }

  /// Áp dụng mã giảm giá
  Future<Map<String, dynamic>> applyDiscount(String code) async {
    _isLoading = true;
    notifyListeners();

    final result = await _cartService.applyDiscount(code: code);

    _isLoading = false;

    if (result['success'] == true) {
      _cart = result['cart'] as CartModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result;
  }

  /// Gỡ mã giảm giá
  Future<Map<String, dynamic>> removeDiscount() async {
    _isLoading = true;
    notifyListeners();

    final result = await _cartService.removeDiscount();

    _isLoading = false;

    if (result['success'] == true) {
      _cart = result['cart'] as CartModel;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result;
  }

  /// Kiểm tra product có trong giỏ không
  bool hasProduct(String productId) {
    return _cart?.hasProduct(productId) ?? false;
  }

  /// Lấy quantity của product
  int getQuantity(String productId) {
    return _cart?.getQuantity(productId) ?? 0;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset cart (khi logout)
  void reset() {
    _cart = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
