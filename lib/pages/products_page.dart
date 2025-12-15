import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';
import '../service/product_service.dart';
import '../service/category_service.dart';
import '../service/brand_service.dart';
import '../service/api_client.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  final String? categoryId;
  final String? brandId;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;

  const ProductsPage({
    super.key,
    this.categoryId,
    this.brandId,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ProductService _productService;
  late final CategoryService _categoryService;
  late final BrandService _brandService;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  Map<String, dynamic>? _pagination;

  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedBrandId;
  String _sortBy = 'newest';

  int _currentPage = 1;
  final int _limit = 12;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(ApiClient());
    _categoryService = CategoryService(ApiClient());
    _brandService = BrandService(ApiClient());

    _selectedCategoryId = widget.categoryId;
    _selectedBrandId = widget.brandId;
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    if (widget.minPrice != null) {
      _minPriceController.text = widget.minPrice!.toString();
    }
    if (widget.maxPrice != null) {
      _maxPriceController.text = widget.maxPrice!.toString();
    }

    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadCategories(),
      _loadBrands(),
    ]);
    await _loadProducts();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _categoryService.getAllCategories();
      if (result['success'] == true && mounted) {
        setState(() {
          _categories = result['categories'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadBrands() async {
    try {
      final result = await _brandService.getAllBrands();
      if (result['success'] == true && mounted) {
        setState(() {
          _brands = result['brands'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading brands: $e');
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _productService.getAllProducts(
        category: _selectedCategoryId,
        brand: _selectedBrandId,
        minPrice: _minPriceController.text.isNotEmpty
            ? double.tryParse(_minPriceController.text)
            : null,
        maxPrice: _maxPriceController.text.isNotEmpty
            ? double.tryParse(_maxPriceController.text)
            : null,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        sort: _sortBy,
        page: _currentPage,
        limit: _limit,
      );

      if (result['success'] == true && mounted) {
        setState(() {
          _products = result['products'] ?? [];
          _pagination = result['pagination'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Không thể tải sản phẩm';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Đã có lỗi xảy ra: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() => _currentPage = 1);
    _loadProducts();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _sortBy = 'newest';
      _currentPage = 1;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Tất cả sản phẩm'),
      ),
      body: Column(
        children: [
          _buildSortBar(),
          Expanded(
            child: _buildProductsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFiltersBottomSheet,
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.char300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Xóa tất cả'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFiltersContent(),
                  ],
                ),
              ),
              Container(
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tìm kiếm',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tên sản phẩm...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Danh mục',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: const Text('Tất cả danh mục'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Tất cả danh mục'),
            ),
            ..._categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Thương hiệu',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBrandId,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: const Text('Tất cả thương hiệu'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Tất cả thương hiệu'),
            ),
            ..._brands.map((brand) {
              return DropdownMenuItem<String>(
                value: brand.id,
                child: Text(brand.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedBrandId = value);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Khoảng giá',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                decoration: InputDecoration(
                  hintText: 'Từ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                decoration: InputDecoration(
                  hintText: 'Đến',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.char200),
        ),
      ),
      child: Row(
        children: [
          if (_pagination != null)
            Expanded(
              child: Text(
                'Hiển thị ${_products.length} / ${_pagination!['total']} sản phẩm',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.char600,
                    ),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                DropdownMenuItem(value: 'oldest', child: Text('Cũ nhất')),
                DropdownMenuItem(value: 'price-asc', child: Text('Giá tăng dần')),
                DropdownMenuItem(value: 'price-desc', child: Text('Giá giảm dần')),
                DropdownMenuItem(value: 'name-asc', child: Text('Tên A-Z')),
                DropdownMenuItem(value: 'name-desc', child: Text('Tên Z-A')),
                DropdownMenuItem(value: 'best-seller', child: Text('Bán chạy')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                    _currentPage = 1;
                  });
                  _loadProducts();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: _buildListView(),
        ),
        if (_pagination != null) _buildPagination(),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductListItem(_products[index]);
      },
    );
  }

  Widget _buildProductListItem(ProductModel product) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final isInWishlist = wishlistProvider.isInWishlist(product.id);

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
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.beige100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images.first,
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
                    if (product.model3DUrl != null && product.model3DUrl!.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primary500,
                                AppTheme.primary700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary500.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.view_in_ar,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '3D',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category != null || product.brand != null)
                      Text(
                        product.category?.name ?? product.brand?.name ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.char600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.totalReviews > 0
                              ? '${product.averageRating.toStringAsFixed(1)} (${product.totalReviews} đánh giá)'
                              : 'Chưa có đánh giá',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: product.totalReviews > 0 ? AppTheme.char900 : AppTheme.char600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatCurrency(product.price),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primary500,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : AppTheme.char600,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _toggleWishlist(product),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _addToCart(product),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: const Text('Thêm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (_pagination == null) return const SizedBox.shrink();

    final totalPages = _pagination!['totalPages'] ?? 1;
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.char200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadProducts();
                  }
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Trang $_currentPage / $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadProducts();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.char300,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sản phẩm',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Thử điều chỉnh bộ lọc hoặc tìm kiếm khác',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearFilters,
              child: const Text('Xóa bộ lọc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Đã có lỗi xảy ra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Không thể tải sản phẩm',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleWishlist(ProductModel product) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để sử dụng wishlist'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final wishlistProvider = context.read<WishlistProvider>();
    final isInWishlist = wishlistProvider.isInWishlist(product.id);

    if (isInWishlist) {
      await wishlistProvider.removeProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi danh sách yêu thích'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await wishlistProvider.addProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm vào danh sách yêu thích'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cartProvider = context.read<CartProvider>();
    final result = await cartProvider.addToCart(
      productId: product.id,
      quantity: 1,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Đã thêm vào giỏ hàng'
                : result['message'] ?? 'Có lỗi xảy ra',
          ),
          backgroundColor:
              result['success'] == true ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )} đ';
  }
}
