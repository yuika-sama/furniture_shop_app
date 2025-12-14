import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../pages/product_detail_page.dart';

/// Product card component with image, title, price, and add to cart button
class ProductCard extends StatefulWidget {
  final String? productId;
  final String? productSlug;
  final String imageUrl;
  final String title;
  final String category;
  final String? brand;
  final double price;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    this.productId,
    this.productSlug,
    required this.imageUrl,
    required this.title,
    required this.category,
    this.brand,
    required this.price,
    this.onTap,
    this.onAddToCart,
    this.onToggleFavorite,
    this.isFavorite = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap ?? (widget.productSlug != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    productSlug: widget.productSlug!,
                  ),
                ),
              );
            }
          : null),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image with Favorite Button - Fixed height
              SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.beige100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: widget.imageUrl.startsWith('http')
                            ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: AppTheme.beige100,
                                    height: 180,
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
                                    height: 180,
                                    child: const Center(
                                      child: Icon(
                                        Icons.chair_outlined,
                                        size: 64,
                                        color: AppTheme.char300,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.beige100,
                                    height: 180,
                                    child: const Center(
                                      child: Icon(
                                        Icons.chair_outlined,
                                        size: 64,
                                        color: AppTheme.char300,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: widget.onToggleFavorite,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: widget.isFavorite
                                ? AppTheme.error
                                : AppTheme.char600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Add to Cart Button - Fixed height
              Container(
                height: 40,
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ElevatedButton.icon(
                  onPressed: widget.onAddToCart,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text(
                    'Thêm vào giỏ',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary500,
                    elevation: 0,
                    side: BorderSide(color: AppTheme.primary500, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Product Info - Fixed height
              Container(
                height: 100,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category and Brand - Fixed height
                    SizedBox(
                      height: 14,
                      child: Text(
                        widget.brand != null
                            ? '${widget.category} • ${widget.brand}'
                            : widget.category,
                        style: const TextStyle(
                          color: AppTheme.info,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product Title - Fixed height for 2 lines
                    SizedBox(
                      height: 38,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.char900,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // Price - Fixed height
                    Text(
                      '${_formatPrice(widget.price)} ₫',
                      style: const TextStyle(
                        color: AppTheme.primary500,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
