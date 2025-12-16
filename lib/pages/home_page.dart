import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/promotion_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../components/app_bar_actions.dart';
import '../components/product_card.dart';
import 'products_page.dart';
import 'product_detail_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final promotionProvider = context.read<PromotionProvider>();
    
    // Load category tree, new arrivals, best sellers and promotions in parallel
    await Future.wait([
      categoryProvider.loadCategoryTree(),
      productProvider.loadNewArrivals(limit: 6),
      productProvider.loadBestSellers(limit: 6),
      promotionProvider.loadPromotions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text(
              'Homi Furniture',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: const [CommonAppBarActions()],
          ),

          // Banner Slider
          SliverToBoxAdapter(
            child: _buildBannerSlider(),
          ),

          // Quick Categories
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'Danh mục nổi bật',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildQuickCategories(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Promotional Banner
          SliverToBoxAdapter(
            child: _buildPromoBanner(),
          ),

          // Featured Products Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sản phẩm nổi bật',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductsPage(),
                        ),
                      );
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
            ),
          ),

          // Featured Products Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55, // Width:Height ratio for fixed size cards
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildProductCard(index),
                childCount: 6,
              ),
            ),
          ),

          // Best Sellers Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bán chạy nhất',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductsPage(),
                        ),
                      );
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
            ),
          ),

          // Best Sellers Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildBestSellerCard(index),
                childCount: 6,
              ),
            ),
          ),

          // Promotions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khuyến mãi đặc biệt',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildPromotionBanner(),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    final bannerData = [
      {
        'image': 'assets/homepage_slider/1.jpg',
        'icon': Icons.local_shipping_outlined,
        'title': 'Miễn phí vận chuyển',
        'subtitle': 'Đơn hàng từ 2 triệu',
      },
      {
        'image': 'assets/homepage_slider/2.jpg',
        'icon': Icons.verified_user_outlined,
        'title': 'Bảo hành 12 tháng',
        'subtitle': 'Chính sách bảo hành',
      },
      {
        'image': 'assets/homepage_slider/3.jpg',
        'icon': Icons.headset_mic_outlined,
        'title': 'Hỗ trợ 24/7',
        'subtitle': 'Tư vấn miễn phí',
      },
      {
        'image': 'assets/homepage_slider/4.jpg',
        'icon': Icons.refresh,
        'title': 'Đổi trả 30 ngày',
        'subtitle': 'Hoàn tiền 100%',
      },
    ];

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: bannerData.length,
            itemBuilder: (context, index) {
              final banner = bannerData[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.beige100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image
                      Image.asset(
                        banner['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback gradient if image not found
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primary400, AppTheme.primary600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      // Overlay gradient for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              // ignore: deprecated_member_use
                              Colors.black.withOpacity(0.4),
                              // ignore: deprecated_member_use
                              Colors.black.withOpacity(0.2),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                banner['icon'] as IconData,
                                size: 40,
                                color: AppTheme.primary500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              banner['title'] as String,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['subtitle'] as String,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Page indicator
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentBannerIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.rootCategories;

        if (categoryProvider.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsPage(
                        categoryId: category.id,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 180,
                  height: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image from API
                      category.image != null && category.image!.isNotEmpty
                          ? Image.network(
                              category.image!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: AppTheme.beige100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.beige100,
                                  child: const Center(
                                    child: Icon(
                                      Icons.category_outlined,
                                      size: 48,
                                      color: AppTheme.char400,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppTheme.beige100,
                              child: const Center(
                                child: Icon(
                                  Icons.category_outlined,
                                  size: 48,
                                  color: AppTheme.char400,
                                ),
                              ),
                            ),
                      // Gradient overlay at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(int index) {
    return Consumer4<ProductProvider, WishlistProvider, CartProvider, AuthProvider>(
      builder: (context, productProvider, wishlistProvider, cartProvider, authProvider, child) {
        // Use real data from API
        final newArrivals = productProvider.newArrivals;
        
        if (newArrivals.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.beige100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = newArrivals[index % newArrivals.length];
        final isFavorite = wishlistProvider.isInWishlist(product.id);

        return ProductCard(
          productId: product.id,
          productSlug: product.slug,
          imageUrl: product.images.isNotEmpty 
              ? product.images[0] 
              : 'https://via.placeholder.com/400x400?text=${Uri.encodeComponent(product.name)}',
          title: product.name,
          category: product.category?.name ?? '',
          brand: product.brand?.name,
          price: product.price,
          isFavorite: isFavorite,
          model3DUrl: product.model3DUrl,
          stock: product.stock,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                  productSlug: product.slug,
                  initialProduct: product,
                ),
              ),
            );
          },
          onAddToCart: () async {
            // Kiểm tra đăng nhập
            if (!authProvider.isLoggedIn) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.error,
                  ),
                );
                
                // Navigate to login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
              return;
            }
            
            final result = await cartProvider.addToCart(
              productId: product.id,
              quantity: 1,
            );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? 'Đã thêm "${product.name}" vào giỏ hàng'
                        : result['message'] ?? 'Không thể thêm vào giỏ hàng',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: result['success'] == true 
                      ? AppTheme.success 
                      : AppTheme.error,
                ),
              );
            }
          },
          onToggleFavorite: () async {
            // Kiểm tra đăng nhập
            if (!authProvider.isLoggedIn) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng đăng nhập để thêm vào danh sách yêu thích'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.error,
                  ),
                );
                
                // Navigate to login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
              return;
            }
            
            await wishlistProvider.toggleProduct(product.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Đã xóa "${product.name}" khỏi danh sách yêu thích'
                        : 'Đã thêm "${product.name}" vào danh sách yêu thích',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildBestSellerCard(int index) {
    return Consumer4<ProductProvider, WishlistProvider, CartProvider, AuthProvider>(
      builder: (context, productProvider, wishlistProvider, cartProvider, authProvider, child) {
        final bestSellers = productProvider.bestSellers;
        
        if (bestSellers.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.beige100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = bestSellers[index % bestSellers.length];
        final isFavorite = wishlistProvider.isInWishlist(product.id);

        return ProductCard(
          productId: product.id,
          productSlug: product.slug,
          imageUrl: product.images.isNotEmpty 
              ? product.images[0] 
              : 'https://via.placeholder.com/400x400?text=${Uri.encodeComponent(product.name)}',
          title: product.name,
          category: product.category?.name ?? '',
          brand: product.brand?.name,
          price: product.price,
          isFavorite: isFavorite,
          model3DUrl: product.model3DUrl,
          stock: product.stock,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                  productSlug: product.slug,
                  initialProduct: product,
                ),
              ),
            );
          },
          onAddToCart: () async {
            // Kiểm tra đăng nhập
            if (!authProvider.isLoggedIn) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.error,
                  ),
                );
                
                // Navigate to login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
              return;
            }
            
            final result = await cartProvider.addToCart(
              productId: product.id,
              quantity: 1,
            );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['success'] == true
                        ? 'Đã thêm "${product.name}" vào giỏ hàng'
                        : result['message'] ?? 'Không thể thêm vào giỏ hàng',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: result['success'] == true 
                      ? AppTheme.success 
                      : AppTheme.error,
                ),
              );
            }
          },
          onToggleFavorite: () async {
            // Kiểm tra đăng nhập
            if (!authProvider.isLoggedIn) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng đăng nhập để thêm vào danh sách yêu thích'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.error,
                  ),
                );
                
                // Navigate to login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
              return;
            }
            
            await wishlistProvider.toggleProduct(product.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Đã xóa "${product.name}" khỏi danh sách yêu thích'
                        : 'Đã thêm "${product.name}" vào danh sách yêu thích',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildPromotionBanner() {
    return Consumer<PromotionProvider>(
      builder: (context, promotionProvider, child) {
        // Get active promotions
        final activePromotions = promotionProvider.activePromotions;

        if (promotionProvider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.beige100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (activePromotions.isEmpty) {
          return const SizedBox.shrink();
        }

        // Display max 3 promotions
        final displayPromotions = activePromotions.take(3).toList();

        return Column(
          children: displayPromotions.map((promotion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _showPromotionDetails(promotion),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary400.withOpacity(0.1),
                        AppTheme.primary600.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary400.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary400, AppTheme.primary600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  promotion.discountText,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primary600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    promotion.code,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              promotion.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.char700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (promotion.daysRemaining > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Còn ${promotion.daysRemaining} ngày',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppTheme.warning,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.char600,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPromoBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductsPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primary500,
              AppTheme.primary600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary500.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'KHÁM PHÁ NGAY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bộ sưu tập\nmới nhất',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppTheme.primary500,
                      size: 28,
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

  void _showPromotionDetails(promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary400, AppTheme.primary600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          promotion.discountText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'GIẢM GIÁ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    promotion.description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.code, 'Mã khuyến mãi', promotion.code),
                  _buildDetailRow(Icons.calendar_today, 'Hạn sử dụng', promotion.dateRangeText),
                  _buildDetailRow(
                    Icons.shopping_cart,
                    'Đơn tối thiểu',
                    promotion.minSpend > 0
                        ? '${promotion.minSpend.toStringAsFixed(0)}đ'
                        : 'Không giới hạn',
                  ),
                  _buildDetailRow(
                    Icons.check_circle,
                    'Trạng thái',
                    promotion.statusText,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Điều kiện áp dụng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildConditionItem('Áp dụng cho tất cả sản phẩm'),
                  _buildConditionItem(
                    promotion.minSpend > 0
                        ? 'Đơn hàng tối thiểu ${promotion.minSpend.toStringAsFixed(0)}đ'
                        : 'Không giới hạn giá trị đơn hàng',
                  ),
                  _buildConditionItem('Không áp dụng cùng mã khác'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: promotion.isValid
                        ? () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã sao chép mã ${promotion.code}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      promotion.isValid ? 'Sao chép mã' : 'Mã không còn hiệu lực',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.char600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
