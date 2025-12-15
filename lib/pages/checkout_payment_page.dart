import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';
import 'order_success_page.dart';

class CheckoutPaymentPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const CheckoutPaymentPage({
    super.key,
    required this.orderData,
  });

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  late String _paymentMethod;
  late TextEditingController _noteController;
  bool _isPaymentConfirmed = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentMethod = widget.orderData['paymentMethod'] ?? 'COD';
    _noteController = TextEditingController(text: widget.orderData['note'] ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Thanh toán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 16),
                  _buildNoteSection(),
                  const SizedBox(height: 16),
                  _buildOrderItemsSection(),
                  const SizedBox(height: 16),
                  _buildPriceSummarySection(),
                  const SizedBox(height: 16),
                  if (_paymentMethod == 'QR') _buildQRPaymentSection(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, size: 20, color: AppTheme.primary500),
                const SizedBox(width: 8),
                Text(
                  'Phương thức thanh toán',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              value: 'COD',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                  _isPaymentConfirmed = false;
                });
              },
              title: const Text('Thanh toán khi nhận hàng (COD)'),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              value: 'QR',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                  _isPaymentConfirmed = false;
                });
              },
              title: const Text('Chuyển khoản qua QR Code'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, size: 20, color: AppTheme.primary500),
                const SizedBox(width: 8),
                Text(
                  'Ghi chú đơn hàng',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú cho đơn hàng (nếu có)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    final cartItems = widget.orderData['cartItems'] as List<dynamic>?;
    
    if (cartItems == null || cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, size: 20, color: AppTheme.primary500),
                const SizedBox(width: 8),
                Text(
                  'Sản phẩm đã chọn',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...cartItems.map((item) {
              final product = item.product;
              final quantity = item.quantity ?? 1;
              final price = product?.price ?? 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.beige100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product?.images?.isNotEmpty == true
                            ? Image.network(
                                product!.images!.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image,
                                  color: AppTheme.char300,
                                ),
                              )
                            : Icon(Icons.image, color: AppTheme.char300),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? 'Sản phẩm',
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Số lượng: $quantity',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.char600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Text(
                      _formatCurrency(price * quantity),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummarySection() {
    final subTotal = widget.orderData['subTotal'] ?? 0.0;
    final discount = widget.orderData['discount'] ?? 0.0;
    final discountCode = widget.orderData['discountCode'];
    final totalAmount = widget.orderData['totalAmount'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, size: 20, color: AppTheme.primary500),
                const SizedBox(width: 8),
                Text(
                  'Chi tiết thanh toán',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Tổng tiền hàng', _formatCurrency(subTotal)),
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Mã giảm giá${discountCode != null ? " ($discountCode)" : ""}',
                '-${_formatCurrency(discount)}',
                color: AppTheme.success,
              ),
            ],
            const SizedBox(height: 8),
            _buildPriceRow('Phí vận chuyển', 'Miễn phí', color: AppTheme.success),
            const Divider(height: 24),
            _buildPriceRow(
              'Tổng thanh toán',
              _formatCurrency(totalAmount),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRPaymentSection() {
    final totalAmount = widget.orderData['totalAmount'] ?? 0.0;
    final amountInt = totalAmount.toInt();
    final qrUrl = 'https://img.vietqr.io/image/MBBANK-0326433268-compact2.png?amount=$amountInt&accountName=NGUYEN%20DUC%20ANH';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Quét mã QR để thanh toán',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.network(
                qrUrl,
                height: 300,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                        const SizedBox(height: 8),
                        const Text('Không thể tải mã QR'),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Số tiền: ${_formatCurrency(totalAmount)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primary500,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'MB Bank - 0326433268',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.char600,
              ),
            ),
            Text(
              'NGUYEN DUC ANH',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.char600,
              ),
            ),
            const SizedBox(height: 24),
            if (!_isPaymentConfirmed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _mockConfirmPayment,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Xác nhận đã chuyển khoản'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.success,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.success),
                    const SizedBox(width: 8),
                    Text(
                      'Đã xác nhận thanh toán',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Quay lại'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _canPlaceOrder() ? _placeOrder : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Đặt hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isTotal = false, Color? color}) {
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

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  bool _canPlaceOrder() {
    if (_isProcessing) return false;
    if (_paymentMethod == 'QR' && !_isPaymentConfirmed) return false;
    return true;
  }

  void _mockConfirmPayment() {
    // Simulate payment confirmation check
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPaymentConfirmed = true;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác nhận thanh toán thành công'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      final cartProvider = context.read<CartProvider>();
      
      // Lấy thông tin địa chỉ từ orderData
      final addressData = widget.orderData['address'];
      
      // Validate địa chỉ
      if (addressData == null ||
          addressData['fullName'] == null ||
          addressData['phone'] == null ||
          addressData['province'] == null ||
          addressData['district'] == null ||
          addressData['ward'] == null ||
          addressData['address'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thông tin địa chỉ không đầy đủ'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      
      // Tạo ShippingAddress object
      final shippingAddress = ShippingAddress(
        fullName: addressData['fullName'] as String,
        phone: addressData['phone'] as String,
        province: addressData['province'] as String,
        district: addressData['district'] as String,
        ward: addressData['ward'] as String,
        address: addressData['address'] as String,
      );
      
      // Convert payment method string to enum
      final paymentMethod = _paymentMethod == 'COD' 
          ? PaymentMethod.cod 
          : PaymentMethod.bank;
      
      // Tạo transactionId giả lập nếu là chuyển khoản
      String? transactionId;
      if (_paymentMethod == 'QR' && _isPaymentConfirmed) {
        transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Gọi API tạo đơn hàng
      final result = await orderProvider.createOrder(
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        discountCode: widget.orderData['discountCode'],
        notes: _noteController.text.trim(),
      );
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Xóa voucher sau khi đặt hàng thành công
        if (widget.orderData['discountCode'] != null) {
          await cartProvider.removeDiscount();
        }
        
        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(
              orderData: {
                ...widget.orderData,
                'paymentMethod': _paymentMethod,
                'note': _noteController.text.trim(),
                'order': result['order'],
                'orderId': result['order']?.id,
                'orderCode': result['order']?.code,
              },
            ),
          ),
        );
      } else {
        // Hiển thị lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Đặt hàng thất bại'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
