import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../service/category_service.dart';
import '../service/api_client.dart';

/// Category Provider - Quản lý state danh mục
class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService;

  List<CategoryModel> _categories = [];
  List<CategoryModel> _categoryTree = [];
  CategoryModel? _currentCategory;
  
  bool _isLoading = false;
  String? _error;

  CategoryProvider({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService(ApiClient());

  // Getters
  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get categoryTree => _categoryTree;
  CategoryModel? get currentCategory => _currentCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCategories => _categories.isNotEmpty;

  /// Load category tree
  Future<void> loadCategoryTree() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _categoryService.getCategoryTree();

      if (result['success'] == true) {
        _categoryTree = result['categories'];
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading category tree: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all categories with pagination
  Future<void> loadCategories({
    int? page,
    int? limit,
    String? search,
    String? parent,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _categoryService.getAllCategories(
        page: page,
        limit: limit,
        search: search,
        parent: parent,
      );

      if (result['success'] == true) {
        _categories = result['categories'];
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load category by slug
  Future<void> loadCategoryBySlug(String slug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _categoryService.getCategoryBySlug(slug);

      if (result['success'] == true) {
        _currentCategory = result['category'];
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get root categories (no parent)
  List<CategoryModel> get rootCategories {
    return _categoryTree;
  }

  /// Clear current category
  void clearCurrentCategory() {
    _currentCategory = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
