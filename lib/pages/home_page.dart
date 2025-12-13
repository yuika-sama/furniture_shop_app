import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
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
    // Load featured products and promotions
    // Will implement when providers are added
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
                childAspectRatio: 0.52, // Width:Height ratio for fixed size cards
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
                childAspectRatio: 0.52,
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
    final categories = [
      {'name': 'Phòng khách', 'image': 'assets/categories/living_room.jpg'},
      {'name': 'Phòng ngủ', 'image': 'assets/categories/bedroom.jpg'},
      {'name': 'Bộ bàn ăn', 'image': 'assets/categories/dining.jpg'},
      {'name': 'Nhà bếp', 'image': 'assets/categories/kitchen.jpg'},
      {'name': 'Văn phòng', 'image': 'assets/categories/office.jpg'},
    ];

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
                  // Background image
                  Image.asset(
                    category['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image not found
                      return Container(
                        color: AppTheme.beige100,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: AppTheme.char400,
                          ),
                        ),
                      );
                    },
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
                        category['name'] as String,
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
  }

  Widget _buildProductCard(int index) {
    // Sample product data - will be replaced with real data from API
    final sampleProducts = [
      {
        'title': 'Bộ Bàn Ăn 6 Ghế',
        'category': 'Bộ bàn ăn',
        'brand': 'Ashley Furniture',
        'price': 8900000.0,
        'image': 'assets/products/dining_set_1.jpg',
      },
      {
        'title': 'Sofa Góc Phòng Khách',
        'category': 'Phòng khách',
        'brand': 'IKEA',
        'price': 15500000.0,
        'image': 'assets/products/sofa_1.jpg',
      },
      {
        'title': 'Giường Ngủ Hiện Đại',
        'category': 'Phòng ngủ',
        'brand': 'Nội Thất Hòa Phát',
        'price': 12000000.0,
        'image': 'assets/products/bed_1.jpg',
      },
      {
        'title': 'Tủ Bếp Gỗ Cao Cấp',
        'category': 'Nhà bếp',
        'brand': 'Ashley Furniture',
        'price': 25000000.0,
        'image': 'assets/products/kitchen_1.jpg',
      },
      {
        'title': 'Bàn Làm Việc Gỗ Sồi',
        'category': 'Văn phòng',
        'brand': 'IKEA',
        'price': 4500000.0,
        'image': 'assets/products/desk_1.jpg',
      },
      {
        'title': 'Tủ Quần Áo 4 Cánh',
        'category': 'Phòng ngủ',
        'brand': 'Nội Thất Hòa Phát',
        'price': 9800000.0,
        'image': 'assets/products/wardrobe_1.jpg',
      },
    ];

    final product = sampleProducts[index % sampleProducts.length];

    return ProductCard(
      imageUrl: product['image'] as String,
      title: product['title'] as String,
      category: product['category'] as String,
      brand: product['brand'] as String,
      price: product['price'] as double,
      isFavorite: false, // Will be managed by WishlistProvider
      onTap: () {
        // TODO: Navigate to product detail page
        debugPrint('Tapped on: ${product['title']}');
      },
      onAddToCart: () {
        // TODO: Add to cart using CartProvider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${product['title']}" vào giỏ hàng'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onToggleFavorite: () {
        // TODO: Toggle favorite using WishlistProvider
        debugPrint('Toggle favorite: ${product['title']}');
      },
    );
  }

  Widget _buildBestSellerCard(int index) {
    // Best seller products data - will be replaced with real data from API
    final bestSellerProducts = [
      {
        'title': 'Ghế Sofa Góc L',
        'category': 'Phòng khách',
        'brand': 'Ashley Furniture',
        'price': 18900000.0,
        'image': 'assets/products/sofa_2.jpg',
      },
      {
        'title': 'Bàn Ăn Mặt Đá',
        'category': 'Bộ bàn ăn',
        'brand': 'Nội Thất Hòa Phát',
        'price': 12500000.0,
        'image': 'assets/products/dining_set_2.jpg',
      },
      {
        'title': 'Tủ Áo Gỗ Óc Chó',
        'category': 'Phòng ngủ',
        'brand': 'IKEA',
        'price': 16000000.0,
        'image': 'assets/products/wardrobe_2.jpg',
      },
      {
        'title': 'Kệ Tivi Hiện Đại',
        'category': 'Phòng khách',
        'brand': 'Ashley Furniture',
        'price': 7200000.0,
        'image': 'assets/products/tv_stand_1.jpg',
      },
      {
        'title': 'Bộ Giường Tủ Cao Cấp',
        'category': 'Phòng ngủ',
        'brand': 'Nội Thất Hòa Phát',
        'price': 22000000.0,
        'image': 'assets/products/bedroom_set_1.jpg',
      },
      {
        'title': 'Bàn Làm Việc Gaming',
        'category': 'Văn phòng',
        'brand': 'IKEA',
        'price': 6500000.0,
        'image': 'assets/products/desk_2.jpg',
      },
    ];

    final product = bestSellerProducts[index % bestSellerProducts.length];

    return ProductCard(
      imageUrl: product['image'] as String,
      title: product['title'] as String,
      category: product['category'] as String,
      brand: product['brand'] as String,
      price: product['price'] as double,
      isFavorite: false,
      onTap: () {
        // TODO: Navigate to product detail page
        debugPrint('Tapped on best seller: ${product['title']}');
      },
      onAddToCart: () {
        // TODO: Add to cart using CartProvider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${product['title']}" vào giỏ hàng'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onToggleFavorite: () {
        // TODO: Toggle favorite using WishlistProvider
        debugPrint('Toggle favorite best seller: ${product['title']}');
      },
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_offer,
              color: AppTheme.warning,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mã giảm giá 20%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.warning,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Áp dụng cho đơn hàng từ 5 triệu',
                  style: Theme.of(context).textTheme.bodySmall,
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
    );
  }
}
