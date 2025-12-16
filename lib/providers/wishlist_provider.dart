import 'package:flutter/foundation.dart';
import '../models/wishlist_model.dart';
import '../models/product_model.dart';
import '../service/wishlist_service.dart';

/// Wishlist Provider - Quản lý state cho wishlist/favorites
class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService;

  WishlistProvider(this._wishlistService);

  // State
  WishlistModel? _wishlist;
  bool _isLoading = false;
  String? _error;

  // Getters
  WishlistModel? get wishlist => _wishlist;
  List<ProductModel> get products => _wishlist?.products ?? [];
  int get count => _wishlist?.count ?? 0;
  bool get isEmpty => count == 0;
  bool get isNotEmpty => count > 0;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed values
  double get totalValue => _wishlist?.totalValue ?? 0.0;
  double get totalOriginalValue => _wishlist?.totalOriginalValue ?? 0.0;
  double get totalSavings => _wishlist?.totalSavings ?? 0.0;
  int get inStockCount => _wishlist?.inStockCount ?? 0;
  int get outOfStockCount => _wishlist?.outOfStockCount ?? 0;
  List<ProductModel> get productsOnSale => _wishlist?.productsOnSale ?? [];
  List<ProductModel> get productsInStock => _wishlist?.productsInStock ?? [];

  /// Load wishlist
  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _wishlistService.getWishlist();
      _wishlist = response.wishlist;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _wishlist = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add product to wishlist
  Future<bool> addProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _wishlistService.addToWishlist(productId);
      _wishlist = response.wishlist;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Remove product from wishlist
  Future<bool> removeProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _wishlistService.removeFromWishlist(productId);
      _wishlist = response.wishlist;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Toggle product in wishlist (add if not exists, remove if exists)
  Future<bool> toggleProduct(String productId) async {
    if (isInWishlist(productId)) {
      return await removeProduct(productId);
    } else {
      return await addProduct(productId);
    }
  }

  /// Clear all wishlist
  Future<bool> clearWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _wishlistService.clearWishlist();
      _wishlist = null;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlist?.containsProduct(productId) ?? false;
  } 

  void clear() {
    _wishlist = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
