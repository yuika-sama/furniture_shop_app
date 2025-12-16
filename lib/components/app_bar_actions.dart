import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/search_page.dart';
import '../pages/cart_page.dart';
import '../pages/wishlist_page.dart';
import '../pages/login_page.dart';

/// Common actions for app bar (search, wishlist, cart, user)
class CommonAppBarActions extends StatelessWidget {
  final bool showWishlist;
  final List<Widget>? additionalActions;

  const CommonAppBarActions({
    super.key,
    this.showWishlist = true,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
      ],
    );
  }
}
