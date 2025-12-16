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
}
