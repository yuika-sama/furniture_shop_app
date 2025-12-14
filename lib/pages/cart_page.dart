import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import 'product_detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _discountController = TextEditingController();
  bool _isApplyingDiscount = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadCart();
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadCart() async {
    final authProvider = context.read<AuthProvider>();
    
    // Log auth status
    debugPrint('=== CART PAGE - AUTH STATUS ===');
    debugPrint('Is Logged In: ${authProvider.isLoggedIn}');
    debugPrint('Current User: ${authProvider.currentUser?.fullName ?? "null"}');
    debugPrint('User Email: ${authProvider.currentUser?.email ?? "null"}');
    debugPrint('User ID: ${authProvider.currentUser?.id ?? "null"}');
    debugPrint('================================');
    
    if (!authProvider.isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để xem giỏ hàng'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    
    await _loadCart();
  }

  Future<void> _loadCart() async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cart?.items.isNotEmpty ?? false) {
                return TextButton.icon(
                  onPressed: _showClearCartDialog,
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text(
                    'Xóa tất cả',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.errorMessage != null) {
            return _buildErrorState(cartProvider.errorMessage!);
          }

          if (cartProvider.cart == null || cartProvider.cart!.items.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadCart,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.cart!.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.cart!.items[index];
                      return _buildCartItem(item, cartProvider);
                    },
                  ),
                ),
              ),
              _buildCheckoutSection(cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(dynamic item, CartProvider cartProvider) {
    final product = item.product;
    final imageUrl = product?.images?.isNotEmpty == true 
        ? product!.images!.first 
        : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            GestureDetector(
              onTap: product?.slug != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            productSlug: product!.slug,
                            initialProduct: product,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.beige100,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: AppTheme.char400,
                          );
                        },
                      )
                    : const Icon(
                        Icons.chair,
                        size: 40,
                        color: AppTheme.primary400,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: product?.slug != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        productSlug: product!.slug,
                                        initialProduct: product,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Text(
                            product?.name ?? 'Tên sản phẩm',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _removeItem(item.productId, cartProvider),
                        color: AppTheme.char600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(product?.price ?? item.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primary500,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng: ${_formatCurrency(item.total)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      _buildQuantityControl(item, cartProvider),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(dynamic item, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.char300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              await cartProvider.decrementItem(item.productId);
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.remove, size: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppTheme.char300),
              ),
            ),
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          InkWell(
            onTap: () async {
              await cartProvider.incrementItem(item.productId);
            },
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeItem(String productId, CartProvider cartProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await cartProvider.removeItem(productId);
    }
  }

  Widget _buildCheckoutSection(CartProvider cartProvider) {
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
        child: Column(
          children: [
            // Promotion Code
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      prefixIcon: const Icon(Icons.local_offer),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: cartProvider.hasDiscount
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => _removeDiscount(cartProvider),
                            )
                          : null,
                    ),
                    enabled: !cartProvider.hasDiscount,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: cartProvider.hasDiscount || _isApplyingDiscount
                      ? null
                      : () => _applyDiscount(cartProvider),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: _isApplyingDiscount
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Áp dụng'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price Summary
            _buildPriceRow('Tạm tính', _formatCurrency(cartProvider.subTotal)),
            if (cartProvider.hasDiscount) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Giảm giá (${cartProvider.discountCode})',
                '-${_formatCurrency(cartProvider.savings)}',
                color: AppTheme.success,
              ),
            ],
            const SizedBox(height: 8),
            _buildPriceRow('Phí vận chuyển', 'Miễn phí', color: AppTheme.success),
            const Divider(height: 24),
            _buildPriceRow(
              'Tổng cộng',
              _formatCurrency(cartProvider.totalAmount),
              isTotal: true,
            ),
            const SizedBox(height: 16),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handleCheckout();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tiến hành thanh toán'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: AppTheme.char300,
            ),
            const SizedBox(height: 24),
            Text(
              'Giỏ hàng trống',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Hãy thêm sản phẩm vào giỏ hàng\nđể bắt đầu mua sắm',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Khám phá sản phẩm'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Đã có lỗi xảy ra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadCart,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyDiscount(CartProvider cartProvider) async {
    final code = _discountController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã giảm giá'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isApplyingDiscount = true);
    final result = await cartProvider.applyDiscount(code);
    setState(() => _isApplyingDiscount = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đã áp dụng mã giảm giá'),
          backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeDiscount(CartProvider cartProvider) async {
    final result = await cartProvider.removeDiscount();
    
    if (result['success'] == true) {
      _discountController.clear();
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đã gỡ mã giảm giá'),
          backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa giỏ hàng'),
          content: const Text('Bạn có chắc chắn muốn xóa tất cả sản phẩm?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final cartProvider = context.read<CartProvider>();
                await cartProvider.clearCart();
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _handleCheckout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.char300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Xác nhận đơn hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildCheckoutInfoSection(
                    'Địa chỉ giao hàng',
                    Icons.location_on,
                    '123 Nguyễn Văn A, P.1, Q.Tân Bình, TP.HCM\nSĐT: 0901234567',
                    onEdit: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildCheckoutInfoSection(
                    'Phương thức thanh toán',
                    Icons.payment,
                    'Thanh toán khi nhận hàng (COD)',
                    onEdit: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildCheckoutInfoSection(
                    'Ghi chú',
                    Icons.note,
                    'Giao hàng giờ hành chính',
                    onEdit: () {},
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildPriceRow('Tổng tiền hàng', '₫10.000.000'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Giảm giá', '-₫2.000.000', color: AppTheme.success),
                  const SizedBox(height: 8),
                  _buildPriceRow('Phí vận chuyển', '₫50.000'),
                  const Divider(height: 24),
                  _buildPriceRow('Tổng thanh toán', '₫8.050.000', isTotal: true),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Place order
                      Navigator.pop(context);
                      _showOrderSuccess();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Đặt hàng'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCheckoutInfoSection(
    String title,
    IconData icon,
    String content, {
    required VoidCallback onEdit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primary500),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Sửa'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Đặt hàng thành công!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Cảm ơn bạn đã đặt hàng.\nChúng tôi sẽ liên hệ với bạn sớm nhất.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.char600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to orders
              },
              child: const Text('Xem đơn hàng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to home
              },
              child: const Text('Tiếp tục mua sắm'),
            ),
          ],
        );
      },
    );
  }
}
