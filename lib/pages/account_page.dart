import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // If not logged in, show login prompt
          if (userProvider.currentUser == null) {
            return _buildLoginPrompt();
          }

          return CustomScrollView(
            slivers: [
              _buildProfileHeader(userProvider),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildMenuSection(
                      'Đơn hàng',
                      [
                        _MenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Đơn hàng của tôi',
                          onTap: () {
                            // TODO: Navigate to orders
                          },
                        ),
                        _MenuItem(
                          icon: Icons.favorite_border,
                          title: 'Sản phẩm yêu thích',
                          onTap: () {
                            // TODO: Navigate to wishlist
                          },
                        ),
                        _MenuItem(
                          icon: Icons.rate_review_outlined,
                          title: 'Đánh giá của tôi',
                          onTap: () {
                            // TODO: Navigate to reviews
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMenuSection(
                      'Cài đặt tài khoản',
                      [
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: 'Thông tin cá nhân',
                          onTap: () {
                            _showEditProfile();
                          },
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Địa chỉ giao hàng',
                          onTap: () {
                            // TODO: Navigate to addresses
                          },
                        ),
                        _MenuItem(
                          icon: Icons.lock_outline,
                          title: 'Đổi mật khẩu',
                          onTap: () {
                            _showChangePassword();
                          },
                        ),
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Thông báo',
                          onTap: () {
                            // TODO: Navigate to notification settings
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMenuSection(
                      'Hỗ trợ',
                      [
                        _MenuItem(
                          icon: Icons.help_outline,
                          title: 'Trung tâm trợ giúp',
                          onTap: () {
                            // TODO: Navigate to help center
                          },
                        ),
                        _MenuItem(
                          icon: Icons.description_outlined,
                          title: 'Điều khoản & chính sách',
                          onTap: () {
                            // TODO: Navigate to terms
                          },
                        ),
                        _MenuItem(
                          icon: Icons.info_outline,
                          title: 'Về chúng tôi',
                          onTap: () {
                            // TODO: Navigate to about
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OutlinedButton(
                        onPressed: _handleLogout,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: AppTheme.error),
                          foregroundColor: AppTheme.error,
                        ),
                        child: const Text('Đăng xuất'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Phiên bản 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.char400,
                          ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProvider userProvider) {
    final user = userProvider.currentUser;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary500, AppTheme.primary700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: user?.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            user!.avatar!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 40,
                                color: AppTheme.primary500,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primary500,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'Người dùng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 120,
              color: AppTheme.char300,
            ),
            const SizedBox(height: 24),
            Text(
              'Bạn chưa đăng nhập',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Đăng nhập để quản lý đơn hàng,\nlưu sản phẩm yêu thích và nhiều hơn nữa',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to login page
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              child: const Text('Đăng nhập'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // TODO: Navigate to register page
              },
              child: const Text('Đăng ký tài khoản mới'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.char600,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppTheme.primary500),
                    title: Text(item.title),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.char400,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chỉnh sửa thông tin',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Update profile
                          Navigator.pop(context);
                        },
                        child: const Text('Lưu'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đổi mật khẩu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Change password
                          Navigator.pop(context);
                        },
                        child: const Text('Đổi mật khẩu'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
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

    if (confirm == true && mounted) {
      // TODO: Implement logout
      // final authProvider = context.read<AuthProvider>();
      // await authProvider.logout();
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
