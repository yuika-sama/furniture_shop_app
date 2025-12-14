import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../components/product_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWishlist();
    });
  }

  Future<void> _loadWishlist() async {
    final wishlistProvider = context.read<WishlistProvider>();
    await wishlistProvider.loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearConfirmation(),
                tooltip: 'Xóa tất cả',
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWishlist,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadWishlist,
            child: Column(
              children: [
                // Summary Card
                _buildSummaryCard(provider),
                
                // Products Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return ProductCard(
                        imageUrl: product.images.isNotEmpty
                            ? product.images[0]
                            : 'https://via.placeholder.com/400x400',
                        title: product.name,
                        category: product.category?.name ?? '',
                        brand: product.brand?.name,
                        price: product.price,
                        isFavorite: true,
                        onTap: () {
                          // TODO: Navigate to product detail
                          debugPrint('Tapped on: ${product.name}');
                        },
                        onAddToCart: () => _addToCart(product.id),
                        onToggleFavorite: () => _removeFromWishlist(product.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(WishlistProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary400.withOpacity(0.1), AppTheme.primary600.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary400.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${provider.count} sản phẩm',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tổng giá trị: ${_formatCurrency(provider.totalValue)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.char700,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary500,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          if (provider.totalSavings > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 16,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tiết kiệm ${_formatCurrency(provider.totalSavings)}',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
              Icons.favorite_border,
              size: 100,
              color: AppTheme.char300,
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có sản phẩm yêu thích',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Khám phá và thêm những sản phẩm\nbạn yêu thích vào danh sách',
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
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Khám phá ngay'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(String productId) async {
    final cartProvider = context.read<CartProvider>();
    final result = await cartProvider.addToCart(productId: productId, quantity: 1);

    if (mounted) {
      final success = result['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã thêm vào giỏ hàng' : 'Không thể thêm vào giỏ hàng'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? AppTheme.success : AppTheme.error,
        ),
      );
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    final wishlistProvider = context.read<WishlistProvider>();
    final success = await wishlistProvider.removeProduct(productId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã xóa khỏi yêu thích' : 'Không thể xóa'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? AppTheme.success : AppTheme.error,
        ),
      );
    }
  }

  Future<void> _showClearConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa tất cả'),
          content: const Text('Bạn có chắc chắn muốn xóa tất cả sản phẩm yêu thích?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('Xóa tất cả'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final wishlistProvider = context.read<WishlistProvider>();
      final success = await wishlistProvider.clearWishlist();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã xóa tất cả' : 'Không thể xóa'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    }
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }
}
