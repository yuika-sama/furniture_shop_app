import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/product_model.dart';
import '../service/api_client.dart';
import '../service/product_service.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final String productSlug;
  final ProductModel? initialProduct; // Dùng để hiển thị nhanh trong khi chờ API

  const ProductDetailPage({
    super.key,
    required this.productSlug,
    this.initialProduct,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late final ProductService _productService;
  late final ApiClient _apiClient; // Khởi tạo 1 lần để dùng lại
  late final TabController _tabController;
  
  ProductModel? _product;
  List<ProductModel> _relatedProducts = [];
  bool _isLoading = true;
  String? _error;
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _productService = ProductService(_apiClient);
    _tabController = TabController(length: 3, vsync: this);
    
    // Sử dụng initialProduct nếu có để hiển thị nhanh
    if (widget.initialProduct != null) {
      _product = widget.initialProduct;
      _isLoading = false;
    }
    
    _loadProductDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    if (!mounted) return;
    
    // Chỉ set loading nếu chưa có initialProduct
    if (widget.initialProduct == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    
    setState(() {
      _quantity = 1;
      _currentImageIndex = 0;
    });

    try {
      // Load chi tiết sản phẩm bằng slug
      final productResult = await _productService.getProductBySlug(widget.productSlug);
      
      if (productResult['success'] != true || productResult['product'] == null) {
        throw Exception(productResult['message'] ?? 'Không tìm thấy sản phẩm');
      }
      
      final product = productResult['product'] as ProductModel;
      
      // Load related products bằng productId
      List<ProductModel> related = [];
      final relatedResult = await _productService.getRelatedProducts(productId: product.id, limit: 8);
      
      if (relatedResult['success'] == true && relatedResult['products'] != null) {
        related = relatedResult['products'] as List<ProductModel>;
      }

      if (mounted) {
        setState(() {
          _product = product;
          _relatedProducts = related;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProductDetail,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _product == null
                  ? const Center(child: Text('Không tìm thấy sản phẩm'))
                  : CustomScrollView(
                      slivers: [
                        _buildAppBar(),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageCarousel(),
                              _buildProductInfo(),
                              _buildQuantityAndActions(),
                              _buildFeatures(),
                              _buildProductMeta(),
                              _buildTabs(),
                              _buildTabContent(),
                              _buildRelatedProducts(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: _product != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng chia sẻ đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    final images = _product!.images;
    
    // FIX: Xử lý trường hợp không có ảnh
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[100],
        child: const Center(
            child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
      );
    }
    
    return Container(
      height: 300,
      color: Colors.grey[100],
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                _apiClient.getImageUrl(images[index]), // Dùng biến _apiClient
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                  );
                },
              );
            },
          ),
          // Navigation arrows
          if (images.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: _currentImageIndex > 0
                      ? () {
                          setState(() {
                            _currentImageIndex--;
                          });
                        }
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: _currentImageIndex < images.length - 1
                      ? () {
                          setState(() {
                            _currentImageIndex++;
                          });
                        }
                      : null,
                ),
              ),
            ),
          ],
          // Image indicators
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? AppTheme.primary500
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          // Sale badge
          if (_product!.hasDiscount)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Sale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_product!.category != null)
            Text(
              _product!.category!.name,
              style: TextStyle(
                color: AppTheme.char400,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _product!.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < _product!.averageRating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${_product!.totalReviews} đánh giá',
                style: TextStyle(
                  color: AppTheme.char400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_product!.price.toStringAsFixed(0)} đ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary500,
                ),
              ),
              if (_product!.hasDiscount) ...[
                const SizedBox(width: 12),
                Text(
                  '${_product!.originalPrice?.toStringAsFixed(0)} đ',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.char400,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Số lượng:',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.char600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.char300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: _quantity > 1
                      ? () {
                          setState(() {
                            _quantity--;
                          });
                        }
                      : null,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _quantity < _product!.stock
                      ? () {
                          setState(() {
                            _quantity++;
                          });
                        }
                      : null,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_product!.stock} có sẵn',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.char400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatureItem(
              Icons.local_shipping_outlined,
              'Miễn phí vận chuyển từ 2 triệu',
            ),
          ),
          Expanded(
            child: _buildFeatureItem(
              Icons.sync_outlined,
              'Đổi hàng 12 tháng',
            ),
          ),
          Expanded(
            child: _buildFeatureItem(
              Icons.assignment_return_outlined,
              'Đổi trả 30 ngày',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary500, size: 32),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildProductMeta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          if (_product!.sku != null)
            _buildMetaRow('SKU:', _product!.sku!),
          if (_product!.category != null)
            _buildMetaRow('Danh mục:', _product!.category!.name),
          if (_product!.brand != null)
            _buildMetaRow('Thương hiệu:', _product!.brand!.name),
          if (_product!.materials.isNotEmpty)
            _buildMetaRow('Chất liệu:', _product!.materials.join(', ')),
          if (_product!.colors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Màu sắc:',
                      style: TextStyle(
                        color: AppTheme.char600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _product!.colors.map((color) {
                        return Chip(
                          label: Text(
                            color,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.grey[200],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.char600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.char300),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primary500,
        unselectedLabelColor: AppTheme.char600,
        indicatorColor: AppTheme.primary500,
        tabs: [
          const Tab(text: 'Mô tả'),
          const Tab(text: 'Thông số'),
          Tab(text: 'Đánh giá (${_product!.totalReviews})'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDescriptionTab(),
          _buildSpecsTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        _product!.description ?? 'Không có mô tả',
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildSpecsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_product!.dimensions != null) ...[
            const Text(
              'Kích thước',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSpecRow('Rộng', '${_product!.dimensions!.width} cm'),
            _buildSpecRow('Cao', '${_product!.dimensions!.height} cm'),
            _buildSpecRow('Dài', '${_product!.dimensions!.length} cm'),
            const SizedBox(height: 16),
          ],
          if (_product!.colors.isNotEmpty) ...[
            const Text(
              'Màu sắc sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _product!.colors.map((color) {
                return Chip(
                  label: Text(color),
                  backgroundColor: AppTheme.primary100,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (_product!.materials.isNotEmpty) ...[
            const Text(
              'Chất liệu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _product!.materials.map((material) {
                return Chip(
                  label: Text(material),
                  backgroundColor: AppTheme.primary100,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppTheme.char600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: AppTheme.char300),
          const SizedBox(height: 16),
          Text(
            'Chưa có đánh giá',
            style: TextStyle(color: AppTheme.char600),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    if (_relatedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Sản phẩm liên quan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _relatedProducts.length,
            itemBuilder: (context, index) {
              return _buildRelatedProductCard(_relatedProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductCard(ProductModel product) {
    // FIX: Check an toàn cho mảng ảnh
    final imageUrl = product.images.isNotEmpty 
        ? _apiClient.getImageUrl(product.images.first) 
        : ''; 

    return GestureDetector(
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
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: imageUrl.isNotEmpty 
                  ? Image.network(
                    imageUrl,
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  )
                  : Container(
                    height: 160,
                    width: 160,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.price.toStringAsFixed(0)} đ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, child) {
                final isInWishlist = wishlistProvider.isInWishlist(_product!.id);
                return IconButton(
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? AppTheme.error : AppTheme.char600,
                  ),
                  style: IconButton.styleFrom(
                    side: BorderSide(color: AppTheme.char300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await wishlistProvider.toggleProduct(_product!.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isInWishlist
                                ? 'Đã xóa khỏi danh sách yêu thích'
                                : 'Đã thêm vào danh sách yêu thích',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _product!.inStock ? _handleAddToCart : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(_product!.inStock ? 'Thêm vào giỏ' : 'Hết hàng'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF8B6F47),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.char300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    final cartProvider = context.read<CartProvider>();
    
    final result = await cartProvider.addToCart(
      productId: _product!.id,
      quantity: _quantity,
    );

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm $_quantity sản phẩm vào giỏ hàng'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Xem giỏ hàng',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
        setState(() {
          _quantity = 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Có lỗi xảy ra'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}