import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../service/api_client.dart';
import '../service/product_service.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/review_provider.dart';
import '../components/product_card.dart';
import 'product_3d_viewer_page.dart';
import 'product_ar_viewer_page.dart';
import 'login_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productSlug;
  final ProductModel? initialProduct;

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
  late final ApiClient _apiClient;
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
        
        // Load reviews sau khi có product ID 
        try {
          final reviewProvider = context.read<ReviewProvider>();
          await reviewProvider.loadReviewsByProduct(product.id);
        } catch (reviewError) {
          // Không crash page nếu reviews fail
        }
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
      backgroundColor: const Color(0xFFFAFAFA),
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
                              const SizedBox(height: 8),
                              _buildProductInfo(),
                              const SizedBox(height: 16),
                              _buildQuantityAndActions(),
                              const SizedBox(height: 16),
                              _buildFeatures(),
                              const SizedBox(height: 24),
                              _buildProductMeta(),
                              const SizedBox(height: 16),
                              _buildTabs(),
                              _buildTabContent(),
                              const SizedBox(height: 24),
                              _buildRelatedProducts(),
                              const SizedBox(height: 100),
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
      backgroundColor: AppTheme.primary500,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () async {
            // Tạm thời gọi trực tiếp thay vì thông qua service
            final url = 'https://furniture-shop-frontend-two.vercel.app/products/${_product!.slug}';
            await Clipboard.setData(ClipboardData(text: url));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã copy đường dẫn sản phẩm'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _build3DButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary500,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = _product!.images;
    
    if (images.isEmpty) {
      return Container(
        height: 350,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.beige100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 80, color: AppTheme.char300),
        ),
      );
    }
    
    return Container(
      height: 350,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                  _apiClient.getImageUrl(images[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.beige100,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 80, color: AppTheme.char300),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Image indicators
            if (images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentImageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: _currentImageIndex == index
                            ? AppTheme.primary500
                            : Colors.white.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.error, Color(0xFFE53935)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.error.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Stock badge
            if (_product!.stock < 10 && _product!.stock > 0)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Chỉ còn ${_product!.stock}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // 3D và AR buttons
            if (_product!.model3DUrl != null && _product!.model3DUrl!.isNotEmpty)
              Positioned(
                bottom: 20,
                right: 16,
                child: Row(
                  children: [
                    _build3DButton(Icons.view_in_ar_outlined, '3D', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Product3DViewerPage(
                            product: _product!,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    _build3DButton(Icons.camera_alt_outlined, 'AR', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductNativeARPage(
                            product: _product!,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_product!.category != null)
            Text(
              _product!.category!.name,
              style: TextStyle(
                color: AppTheme.char500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _product!.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.char900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (index) {
                final rating = _product!.averageRating;
                if (index < rating.floor()) {
                  return const Icon(Icons.star, size: 16, color: Colors.amber);
                } else if (index < rating && rating % 1 != 0) {
                  return const Icon(Icons.star_half, size: 16, color: Colors.amber);
                } else {
                  return Icon(Icons.star_border, size: 16, color: Colors.grey[300]);
                }
              }),
              const SizedBox(width: 8),
              Text(
                '${_product!.averageRating.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.char900,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${_product!.totalReviews})',
                style: TextStyle(
                  color: AppTheme.char500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_product!.price.toStringAsFixed(0).replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]}.',
                )} ₫',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary500,
                ),
              ),
              if (_product!.hasDiscount) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_product!.originalPrice?.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )} ₫',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.char400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Số lượng:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.char900,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary50, AppTheme.beige50],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary200, width: 1.5),
            ),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _quantity > 1
                        ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                        : null,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: _quantity > 1 ? AppTheme.primary500 : AppTheme.char300,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary500,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _quantity < _product!.stock
                        ? () {
                            setState(() {
                              _quantity++;
                            });
                          }
                        : null,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: _quantity < _product!.stock
                            ? AppTheme.primary500
                            : AppTheme.char300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _product!.stock > 10
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _product!.stock > 10 ? AppTheme.success : AppTheme.error,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _product!.stock > 10 ? Icons.check_circle : Icons.warning_rounded,
                  size: 16,
                  color: _product!.stock > 10 ? AppTheme.success : AppTheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_product!.stock} có sẵn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _product!.stock > 10 ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatureItem(
              Icons.local_shipping_outlined,
              'Miễn phí\nvận chuyển',
              AppTheme.primary500,
              AppTheme.primary50,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureItem(
              Icons.verified_user_outlined,
              'Bảo hành\n12 tháng',
              AppTheme.success,
              AppTheme.success.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureItem(
              Icons.assignment_return_outlined,
              'Đổi trả\n30 ngày',
              AppTheme.info,
              AppTheme.info.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.char700,
              height: 1.3,
            ),
          ),
        ],
      ),
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
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary50,
                            border: Border.all(color: AppTheme.primary200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            color,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.char900,
        unselectedLabelColor: AppTheme.char500,
        indicatorColor: AppTheme.primary500,
        indicatorWeight: 2,
        tabs: [
          const Tab(text: 'Mô tả'),
          const Tab(text: 'Thông số'),
          Tab(text: 'Đánh giá (${_product!.totalReviews})'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      color: Colors.white,
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
      padding: const EdgeInsets.all(20),
      child: Text(
        _product!.description ?? 'Không có mô tả',
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: AppTheme.char700,
        ),
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
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary50,
                    border: Border.all(color: AppTheme.primary200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    color,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.beige100,
                    border: Border.all(color: AppTheme.beige200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    material,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.char800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        if (reviewProvider.isLoading && reviewProvider.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (reviewProvider.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: AppTheme.char400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chưa có đánh giá',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.char700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy là người đầu tiên đánh giá sản phẩm này',
                  style: TextStyle(
                    color: AppTheme.char500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reviewProvider.reviews.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final review = reviewProvider.reviews[index];
            return _buildReviewItem(review);
          },
        );
      },
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.beige50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.char200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary100,
                backgroundImage: review.userDetails?.avatar != null && review.userDetails!.avatar!.isNotEmpty
                    ? NetworkImage(review.userDetails!.avatar!)
                    : null,
                child: review.userDetails?.avatar == null || review.userDetails!.avatar!.isEmpty
                    ? Text(
                        review.userDetails?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          color: AppTheme.primary500,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userDetails?.fullName ?? 'Người dùng',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.char900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatReviewDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.char500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.char700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }

  Widget _buildRelatedProducts() {
    if (_relatedProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Sản phẩm liên quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.char900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 360,
            child: Consumer3<WishlistProvider, CartProvider, AuthProvider>(
              builder: (context, wishlistProvider, cartProvider, authProvider, child) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _relatedProducts.length,
                  itemBuilder: (context, index) {
                  final product = _relatedProducts[index];
                  final isFavorite = wishlistProvider.isInWishlist(product.id);
                  
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    child: ProductCard(
                      productId: product.id,
                      productSlug: product.slug,
                      imageUrl: product.images.isNotEmpty
                          ? product.images.first
                          : '',
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
                        if (!authProvider.isLoggedIn) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.error,
                              ),
                            );
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
                        if (!authProvider.isLoggedIn) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng đăng nhập để thêm vào danh sách yêu thích'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.error,
                              ),
                            );
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
                    ),
                  );
                },
              );
            },
           ),
        ),
      ],
    ));
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
                      borderRadius: BorderRadius.circular(4),
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
                  backgroundColor: AppTheme.primary500,
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