import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import 'product_detail_page.dart';
import 'checkout_payment_page.dart';
import 'address_management_page.dart';
import '../service/address_service.dart';
import '../service/api_client.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _discountController = TextEditingController();
  bool _isApplyingDiscount = false;
  
  // Checkout state
  late final AddressService _addressService;
  List<dynamic> _addresses = [];
  dynamic _selectedAddress;
  String _paymentMethod = 'COD'; // 'COD' or 'QR'
  final TextEditingController _noteController = TextEditingController();
  bool _isLoadingAddresses = false;

  @override
  void initState() {
    super.initState();
    _addressService = AddressService(ApiClient());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadCart();
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    _noteController.dispose();
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
        centerTitle: false,
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

  Future<void> _handleCheckout() async {
    // Load addresses trước
    await _loadAddresses();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
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
                      
                      // Địa chỉ giao hàng
                      _buildAddressSection(setModalState),
                      const SizedBox(height: 16),
                      
                      // Phương thức thanh toán
                      _buildPaymentMethodSection(setModalState),
                      const SizedBox(height: 16),
                      
                      // Ghi chú
                      _buildNoteSection(),
                      const SizedBox(height: 24),
                      
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Chi tiết giá
                      _buildCheckoutPriceDetails(),
                      
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _selectedAddress == null
                            ? null
                            : () {
                                Navigator.pop(context);
                                _proceedToPayment();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Xác nhận thanh toán'),
                      ),
                    ],
                  ),
                );
              },
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

  void _proceedToPayment() {
    final cartProvider = context.read<CartProvider>();
    
    final orderData = {
      'address': _selectedAddress,
      'paymentMethod': _paymentMethod,
      'note': _noteController.text.trim(),
      'cartItems': cartProvider.cart?.items,
      'subTotal': cartProvider.subTotal,
      'discount': cartProvider.savings,
      'discountCode': cartProvider.discountCode,
      'totalAmount': cartProvider.totalAmount,
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPaymentPage(orderData: orderData),
      ),
    );
  }
  
  Future<void> _loadAddresses() async {
    setState(() => _isLoadingAddresses = true);
    
    try {
      final result = await _addressService.getAddresses();
      
      if (result['success'] == true && result['addresses'] != null) {
        setState(() {
          _addresses = result['addresses'] as List<dynamic>;
          // Chọn địa chỉ mặc định nếu có
          _selectedAddress = _addresses.firstWhere(
            (addr) => addr['isDefault'] == true,
            orElse: () => _addresses.isNotEmpty ? _addresses.first : null,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      setState(() => _isLoadingAddresses = false);
    }
  }
  
  Widget _buildAddressSection(StateSetter setModalState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: AppTheme.primary500),
                const SizedBox(width: 8),
                Text(
                  'Địa chỉ giao hàng',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAddressSelector(setModalState),
                  child: const Text('Thay đổi'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingAddresses)
              const Center(child: CircularProgressIndicator())
            else if (_selectedAddress != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedAddress['fullName']} - ${_selectedAddress['phone']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedAddress['address']}, ${_selectedAddress['ward']}, ${_selectedAddress['district']}, ${_selectedAddress['province']}',
                  ),
                  if (_selectedAddress['isDefault'] == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mặc định',
                      style: TextStyle(color: AppTheme.primary500, fontSize: 12),
                    ),
                  ],
                ],
              )
            else
              Text(
                'Chưa có địa chỉ giao hàng',
                style: TextStyle(color: AppTheme.char600),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showAddressSelector(StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn địa chỉ giao hàng',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Chưa có địa chỉ nào'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    final isSelected = _selectedAddress?['_id'] == address['_id'];
                    
                    return ListTile(
                      leading: Radio<String>(
                        value: address['_id'],
                        groupValue: _selectedAddress?['_id'],
                        onChanged: (value) {
                          setState(() {
                            _selectedAddress = address;
                          });
                          setModalState(() {
                            _selectedAddress = address;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      title: Text('${address['fullName']} - ${address['phone']}'),
                      subtitle: Text(
                        '${address['address']}, ${address['ward']}, ${address['district']}, ${address['province']}',
                      ),
                      isThreeLine: true,
                      trailing: address['isDefault'] == true
                          ? Chip(
                              label: const Text('Mặc định'),
                              backgroundColor: AppTheme.primary100,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedAddress = address;
                        });
                        setModalState(() {
                          _selectedAddress = address;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // Đóng bottom sheet
                    // Navigate to AddressManagementPage
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressManagementPage(),
                      ),
                    );
                    // Reload addresses after returning
                    if (mounted) {
                      await _loadAddresses();
                      setModalState(() {
                        // Update modal state if needed
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm địa chỉ mới'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPaymentMethodSection(StateSetter setModalState) {
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
                setState(() => _paymentMethod = value!);
                setModalState(() => _paymentMethod = value!);
              },
              title: const Text('Thanh toán khi nhận hàng (COD)'),
              subtitle: const Text('Thanh toán bằng tiền mặt khi nhận hàng'),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              value: 'QR',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() => _paymentMethod = value!);
                setModalState(() => _paymentMethod = value!);
              },
              title: const Text('Chuyển khoản QR'),
              subtitle: const Text('Quét mã QR để thanh toán'),
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
                  'Ghi chú',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú cho đơn hàng (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckoutPriceDetails() {
    final cartProvider = context.watch<CartProvider>();
    
    return Column(
      children: [
        _buildPriceRow('Tổng tiền hàng', _formatCurrency(cartProvider.subTotal)),
        if (cartProvider.hasDiscount) ...[
          const SizedBox(height: 8),
          _buildPriceRow(
            'Mã giảm giá (${cartProvider.discountCode})',
            '-${_formatCurrency(cartProvider.savings)}',
            color: AppTheme.success,
          ),
        ],
        const SizedBox(height: 8),
        _buildPriceRow('Phí vận chuyển', 'Miễn phí', color: AppTheme.success),
        const Divider(height: 24),
        _buildPriceRow(
          'Tổng thanh toán',
          _formatCurrency(cartProvider.totalAmount),
          isTotal: true,
        ),
      ],
    );
  }
}
