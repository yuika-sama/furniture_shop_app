import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/order_provider.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ xử lý'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Đang giao'),
            Tab(text: 'Hoàn thành'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null) {
            return _buildErrorState(orderProvider.error!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderProvider.orders),
              _buildOrderList(orderProvider.pendingOrders),
              _buildOrderList(orderProvider.processingOrders),
              _buildOrderList(orderProvider.shippedOrders),
              _buildOrderList(orderProvider.deliveredOrders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order code and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn hàng #${order.code}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // Order items
              ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Product image
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.beige100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: item.product?.images?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product!.images!.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image,
                                  color: AppTheme.char300,
                                ),
                              ),
                            )
                          : const Icon(Icons.image, color: AppTheme.char300),
                    ),
                    const SizedBox(width: 12),
                    
                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product?.name ?? 'Sản phẩm',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'x${item.quantity}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.char600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Price
                    Text(
                      _formatCurrency(item.price),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary500,
                          ),
                    ),
                  ],
                ),
              )),
              
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Và ${order.items.length - 2} sản phẩm khác',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.char600,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // Footer with total and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng thanh toán',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.char600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(order.totalAmount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primary500,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.char600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = AppTheme.warning.withValues(alpha: 0.1);
        textColor = AppTheme.warning;
        label = 'Chờ xử lý';
        break;
      case OrderStatus.processing:
        backgroundColor = AppTheme.info.withValues(alpha: 0.1);
        textColor = AppTheme.info;
        label = 'Đang xử lý';
        break;
      case OrderStatus.shipped:
        backgroundColor = AppTheme.primary500.withValues(alpha: 0.1);
        textColor = AppTheme.primary500;
        label = 'Đang giao';
        break;
      case OrderStatus.delivered:
        backgroundColor = AppTheme.success.withValues(alpha: 0.1);
        textColor = AppTheme.success;
        label = 'Hoàn thành';
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppTheme.error.withValues(alpha: 0.1);
        textColor = AppTheme.error;
        label = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chi tiết đơn hàng',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Order info
                  _buildDetailRow('Mã đơn hàng', order.code),
                  _buildDetailRow('Trạng thái', _getStatusText(order.status)),
                  _buildDetailRow('Ngày đặt', _formatDate(order.createdAt)),
                  _buildDetailRow(
                    'Phương thức thanh toán',
                    'COD',
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Địa chỉ giao hàng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.shippingAddress.fullName} - ${order.shippingAddress.phone}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${order.shippingAddress.address}, ${order.shippingAddress.ward}, ${order.shippingAddress.district}, ${order.shippingAddress.province}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.char600,
                        ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Sản phẩm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Order items
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.beige100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: item.product?.images?.isNotEmpty == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product!.images!.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      color: AppTheme.char300,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.image, color: AppTheme.char300),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product?.name ?? 'Sản phẩm',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'x${item.quantity}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.char600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(item.price * item.quantity),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Price summary
                  _buildPriceRow('Tạm tính', _formatCurrency(order.subTotal)),
                  if (order.discount.amount > 0) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Giảm giá',
                      '-${_formatCurrency(order.discount.amount)}',
                      color: AppTheme.success,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildPriceRow('Phí vận chuyển', '30000', color: AppTheme.success),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildPriceRow(
                    'Tổng thanh toán',
                    _formatCurrency(order.totalAmount),
                    isTotal: true,
                  ),
                  
                  // Cancel button
                  if (order.status == OrderStatus.pending || order.status == OrderStatus.processing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _cancelOrder(order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                        ),
                        child: const Text('Hủy đơn hàng'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.char600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char700,
                  ),
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary500,
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color ?? AppTheme.char900,
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ],
    );
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final orderProvider = context.read<OrderProvider>();
      final result = await orderProvider.cancelOrder(order.id);

      if (mounted) {
        Navigator.pop(context); // Close details sheet
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? 'Đã hủy đơn hàng thành công'
                  : result['message'] ?? 'Không thể hủy đơn hàng',
            ),
            backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppTheme.char300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy đặt hàng để xem đơn hàng tại đây',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.char600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Đã có lỗi xảy ra',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.char600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xử lý';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipped:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}
