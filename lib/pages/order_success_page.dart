import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'main_scaffold.dart';
import 'orders_page.dart';

class OrderSuccessPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderSuccessPage({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 32),

              // Success Title
              Text(
                'Đặt hàng thành công!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Success Message
              Text(
                orderData['paymentMethod'] == 'COD'
                    ? 'Đơn hàng của bạn đã được ghi nhận.\nChúng tôi sẽ liên hệ với bạn sớm nhất.'
                    : 'Đơn hàng của bạn đã được thanh toán thành công.\nChúng tôi sẽ xử lý và giao hàng sớm nhất.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.char600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Order Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        'Phương thức thanh toán',
                        orderData['paymentMethod'] == 'COD'
                            ? 'Thanh toán khi nhận hàng'
                            : 'Chuyển khoản',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        'Tổng tiền',
                        _formatCurrency(orderData['totalAmount'] ?? 0.0),
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to home with bottom bar and clear all previous routes
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScaffold(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Về trang chủ'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersPage(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Xem đơn hàng'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.char700,
              ),
        ),
        Text(
          value,
          style: isHighlight
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary500,
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
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
}
