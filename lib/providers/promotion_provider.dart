import 'package:flutter/foundation.dart';
import '../models/promotion_model.dart';
import '../service/promotion_service.dart';

/// Promotion Provider - Quản lý state cho promotions
class PromotionProvider extends ChangeNotifier {
  final PromotionService _promotionService;

  PromotionProvider(this._promotionService);

  // State
  List<PromotionModel> _promotions = [];
  PromotionValidationResult? _validationResult;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PromotionModel> get promotions => _promotions;
  PromotionValidationResult? get validationResult => _validationResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered promotions
  List<PromotionModel> get activePromotions =>
      _promotions.where((p) => p.isValid).toList();

  List<PromotionModel> get expiredPromotions =>
      _promotions.where((p) => p.isExpired).toList();

  List<PromotionModel> get upcomingPromotions =>
      _promotions.where((p) => p.isUpcoming).toList();

  /// Load all promotions (public)
  Future<void> loadPromotions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _promotionService.getAllPromotions();
      if (result['success'] == true) {
        _promotions = (result['promotions'] as List<dynamic>)
            .cast<PromotionModel>();
        _error = null;
      } else {
        _error = result['message'] ?? 'Lỗi không xác định';
        _promotions = [];
      }
    } catch (e) {
      _error = e.toString();
      _promotions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validate promotion code
  Future<bool> validateCode(String code, double orderAmount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _promotionService.validatePromotionCode(
        code: code,
        orderAmount: orderAmount,
      );

      if (result['valid'] == true) {
        _validationResult = PromotionValidationResult(
          valid: result['valid'] ?? false,
          message: result['message'] ?? '',
          promotion: result['promotion'],
          discountAmount: result['discountAmount'],
          minSpend: result['minSpend'],
        );
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Mã khuyến mãi không hợp lệ';
        _validationResult = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _validationResult = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Clear validation result
  void clearValidation() {
    _validationResult = null;
    notifyListeners();
  }

  /// Find promotion by code
  PromotionModel? findByCode(String code) {
    try {
      return _promotions.firstWhere(
        (p) => p.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if code exists and is valid
  bool isCodeValid(String code) {
    final promo = findByCode(code);
    return promo?.isValid ?? false;
  }

  // ============ ADMIN FUNCTIONS ============

  /// Create new promotion (Admin)
  Future<bool> createPromotion({
    required String code,
    required String description,
    required DiscountType discountType,
    required double discountValue,
    required DateTime startDate,
    required DateTime endDate,
    double minSpend = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _promotionService.createPromotion(
        code: code,
        description: description,
        discountType: discountType,
        discountValue: discountValue,
        startDate: startDate,
        endDate: endDate,
        minSpend: minSpend,
      );

      if (result['success'] == true) {
        final newPromo = result['promotion'] as PromotionModel;
        _promotions.insert(0, newPromo);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Tạo khuyến mãi thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Update promotion (Admin)
  Future<bool> updatePromotion(
    String id, {
    String? code,
    String? description,
    DiscountType? discountType,
    double? discountValue,
    DateTime? startDate,
    DateTime? endDate,
    double? minSpend,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _promotionService.updatePromotion(
        promotionId: id,
        code: code,
        description: description,
        discountType: discountType,
        discountValue: discountValue,
        startDate: startDate,
        endDate: endDate,
        minSpend: minSpend,
        isActive: isActive,
      );

      if (result['success'] == true) {
        final updated = result['promotion'] as PromotionModel;
        final index = _promotions.indexWhere((p) => p.id == id);
        if (index != -1) {
          _promotions[index] = updated;
        }
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Cập nhật khuyến mãi thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Delete promotion (Admin)
  Future<bool> deletePromotion(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _promotionService.deletePromotion(id);
      _promotions.removeWhere((p) => p.id == id);
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

  /// Toggle promotion active status (Admin)
  Future<bool> toggleActive(String id) async {
    final promo = _promotions.firstWhere((p) => p.id == id);
    return await updatePromotion(id, isActive: !promo.isActive);
  }

  /// Clear all state
  void clear() {
    _promotions = [];
    _validationResult = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
