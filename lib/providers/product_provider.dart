import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../service/product_service.dart';
import '../service/api_client.dart';

/// Product Provider - Quản lý state sản phẩm
class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _newArrivals = [];
  List<ProductModel> _bestSellers = [];
  ProductModel? _currentProduct;
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pagination;

  ProductProvider({ProductService? productService})
      : _productService = productService ?? ProductService(ApiClient());

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get newArrivals => _newArrivals;
  List<ProductModel> get bestSellers => _bestSellers;
  ProductModel? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;
  bool get hasProducts => _products.isNotEmpty;
  bool get hasMore => _pagination != null && 
      _pagination!['page'] < _pagination!['totalPages'];

  /// Load danh sách sản phẩm
  Future<void> loadProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    if (page == 1) {
      _isLoading = true;
      _error = null;
    }
    notifyListeners();

    try {
      final result = await _productService.getAllProducts(
        category: category,
        brand: brand,
        minPrice: minPrice,
        maxPrice: maxPrice,
        search: search,
        sort: sort,
        page: page,
        limit: limit,
      );

      if (result['success'] == true) {
        if (page == 1) {
          _products = result['products'];
        } else {
          _products.addAll(result['products']);
        }
        _pagination = result['pagination'];
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load sản phẩm nổi bật
  Future<void> loadFeaturedProducts({int limit = 8}) async {
    try {
      final result = await _productService.getFeaturedProducts(limit: limit);

      if (result['success'] == true) {
        _featuredProducts = result['products'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading featured products: $e');
    }
  }

  /// Load sản phẩm mới
  Future<void> loadNewArrivals({int limit = 8}) async {
    try {
      final result = await _productService.getNewArrivals(limit: limit);

      if (result['success'] == true) {
        _newArrivals = result['products'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading new arrivals: $e');
    }
  }

  /// Load sản phẩm bán chạy
  Future<void> loadBestSellers({int limit = 8}) async {
    try {
      final result = await _productService.getBestSellers(limit: limit);

      if (result['success'] == true) {
        _bestSellers = result['products'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading best sellers: $e');
    }
  }

  /// Load chi tiết sản phẩm theo slug
  Future<void> loadProductBySlug(String slug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _productService.getProductBySlug(slug);

      if (result['success'] == true) {
        _currentProduct = result['product'];
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm kiếm sản phẩm
  Future<void> searchProducts({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    await loadProducts(
      search: keyword,
      page: page,
      limit: limit,
    );
  }

  /// Lọc theo category
  Future<void> filterByCategory({
    required String categoryId,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    await loadProducts(
      category: categoryId,
      page: page,
      limit: limit,
      sort: sort,
    );
  }

  /// Lọc theo brand
  Future<void> filterByBrand({
    required String brandId,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    await loadProducts(
      brand: brandId,
      page: page,
      limit: limit,
      sort: sort,
    );
  }

  /// Lọc theo khoảng giá
  Future<void> filterByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int limit = 10,
  }) async {
    await loadProducts(
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      limit: limit,
    );
  }

  /// Load more products (pagination)
  Future<void> loadMore() async {
    if (!hasMore || _isLoading) return;

    final nextPage = (_pagination!['page'] as int) + 1;
    await loadProducts(page: nextPage);
  }

  /// Refresh products
  Future<void> refresh() async {
    await loadProducts(page: 1);
  }
}
