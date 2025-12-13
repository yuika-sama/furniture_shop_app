import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/promotion_provider.dart';
import '../components/app_bar_actions.dart';
import '../components/product_card.dart';

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
          SliverAppBar.medium(
            pinned: true,
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
                      // TODO: Navigate to all products
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
                      // TODO: Navigate to best sellers
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
              return Container(
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
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(int index) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
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

        return ProductCard(
          imageUrl: product.images.isNotEmpty 
              ? product.images[0] 
              : 'https://via.placeholder.com/400x400?text=${Uri.encodeComponent(product.name)}',
          title: product.name,
          category: product.category?.name ?? '',
          brand: product.brand?.name,
          price: product.price,
          isFavorite: false, // Will be managed by WishlistProvider
          onTap: () {
            // TODO: Navigate to product detail page
            debugPrint('Tapped on: ${product.name}');
          },
          onAddToCart: () {
            // TODO: Add to cart using CartProvider
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm "${product.name}" vào giỏ hàng'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onToggleFavorite: () {
            // TODO: Toggle favorite using WishlistProvider
            debugPrint('Toggle favorite: ${product.name}');
          },
        );
      },
    );
  }

  Widget _buildBestSellerCard(int index) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Use real data from API
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

        return ProductCard(
          imageUrl: product.images.isNotEmpty 
              ? product.images[0] 
              : 'https://via.placeholder.com/400x400?text=${Uri.encodeComponent(product.name)}',
          title: product.name,
          category: product.category?.name ?? '',
          brand: product.brand?.name,
          price: product.price,
          isFavorite: false,
          onTap: () {
            // TODO: Navigate to product detail page
            debugPrint('Tapped on best seller: ${product.name}');
          },
          onAddToCart: () {
            // TODO: Add to cart using CartProvider
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm "${product.name}" vào giỏ hàng'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onToggleFavorite: () {
            // TODO: Toggle favorite using WishlistProvider
            debugPrint('Toggle favorite best seller: ${product.name}');
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

        // Display first active promotion
        final promotion = activePromotions.first;

        return InkWell(
          onTap: () {
            // Navigate to promotions page
            Navigator.pushNamed(context, '/promotions');
          },
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
                      if (promotion.daysRemaining != null && promotion.daysRemaining! > 0)
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
        );
      },
    );
  }
}
