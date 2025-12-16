import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../service/order_service.dart';
import '../service/api_client.dart';

/// Order Provider - Quản lý state đơn hàng
class OrderProvider with ChangeNotifier {
  final OrderService _orderService;

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  String? _error;

  OrderProvider({OrderService? orderService})
      : _orderService = orderService ?? OrderService(ApiClient());

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrders => _orders.isNotEmpty;

  // Filter orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<OrderModel> get pendingOrders =>
      getOrdersByStatus(OrderStatus.pending);
  List<OrderModel> get processingOrders =>
      getOrdersByStatus(OrderStatus.processing);
  List<OrderModel> get shippedOrders =>
      getOrdersByStatus(OrderStatus.shipped);
  List<OrderModel> get deliveredOrders =>
      getOrdersByStatus(OrderStatus.delivered);
  List<OrderModel> get cancelledOrders =>
      getOrdersByStatus(OrderStatus.cancelled);

  /// Tạo đơn hàng mới
  Future<Map<String, dynamic>> createOrder({
    required ShippingAddress shippingAddress,
    required PaymentMethod paymentMethod,
    String? transactionId,
    String? discountCode,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.createOrder(
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        discountCode: discountCode,
        notes: notes,
      );

      if (result['success'] == true) {
        _currentOrder = result['order'];
        // Add to list
        _orders.insert(0, _currentOrder!);
      } else {
        _error = result['message'];
      }

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: ${e.toString()}',
      };
    }
  }

  /// Load đơn hàng của user
  Future<void> loadMyOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.getMyOrders(
        status: status,
        page: page,
        limit: limit,
      );

      if (result['success'] == true) {
        if (page == 1) {
          _orders = result['orders'];
        } else {
          _orders.addAll(result['orders']);
        }
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

  /// Load chi tiết đơn hàng
  Future<void> loadOrderById(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.getOrderById(orderId);

      if (result['success'] == true) {
        _currentOrder = result['order'];
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

  /// Tra cứu đơn hàng theo code
  Future<Map<String, dynamic>> trackOrderByCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.getOrderByCode(code);

      if (result['success'] == true) {
        _currentOrder = result['order'];
      } else {
        _error = result['message'];
      }

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: ${e.toString()}',
      };
    }
  }

  /// Hủy đơn hàng
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final result = await _orderService.cancelOrder(orderId);

      if (result['success'] == true) {
        // Update order in list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = result['order'];
        }
        
        // Update current order if matches
        if (_currentOrder?.id == orderId) {
          _currentOrder = result['order'];
        }

        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: ${e.toString()}',
      };
    }
  }

  /// Refresh đơn hàng
  Future<void> refresh() async {
    await loadMyOrders(page: 1);
  }
}
