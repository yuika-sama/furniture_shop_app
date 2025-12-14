import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../pages/search_page.dart';
import '../pages/cart_page.dart';
import '../pages/wishlist_page.dart';
import '../pages/login_page.dart';

/// Common app bar with search, wishlist, and cart icons
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showWishlist;
  final List<Widget>? additionalActions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showWishlist = true,
    this.additionalActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        ),
        if (showWishlist)
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng đăng nhập để xem danh sách yêu thích'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        if (additionalActions != null) ...additionalActions!,
        const CartIconWithBadge(),
      ],
    );
  }
}

/// Cart icon with badge showing item count
class CartIconWithBadge extends StatelessWidget {
  const CartIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            final authProvider = context.read<AuthProvider>();
            if (authProvider.isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            } else {
              Navigator.push(
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
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemCount = cartProvider.cart?.items.length ?? 0;
              if (itemCount == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  itemCount > 9 ? '9+' : '$itemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
