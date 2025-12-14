import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/user_provider.dart';
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
        const UserMenuButton(),
      ],
    );
  }
}

/// User menu button with dropdown
class UserMenuButton extends StatelessWidget {
  const UserMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        
        return PopupMenuButton<String>(
          icon: const Icon(Icons.person_outline),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'account':
                // Navigate to account tab in main scaffold
                Navigator.of(context).popUntil((route) => route.isFirst);
                break;
              case 'orders':
                // TODO: Navigate to orders page
                break;
              case 'logout':
                _handleLogout(context);
                break;
            }
          },
          itemBuilder: (context) => [
            // User info header
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Người dùng',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@gmail.com',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.char500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                ],
              ),
            ),
            // Account
            const PopupMenuItem<String>(
              value: 'account',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Tài khoản'),
                ],
              ),
            ),
            // Orders
            const PopupMenuItem<String>(
              value: 'orders',
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Đơn hàng'),
                ],
              ),
            ),
            // Divider
            const PopupMenuDivider(),
            // Logout
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppTheme.error),
                  const SizedBox(width: 12),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
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
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đăng xuất thành công'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
