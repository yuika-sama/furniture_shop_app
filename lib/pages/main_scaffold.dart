import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../service/api_client.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/user_provider.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'chatbot_page.dart';
import 'promotions_page.dart';
import 'account_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const ChatbotPage(),
    const PromotionsPage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Setup callback cho ApiClient để tự động logout khi token hết hạn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiClient = context.read<ApiClient>();
      final authProvider = context.read<AuthProvider>();
      
      // Setup callback to handle unauthorized (token expired)
      apiClient.onUnauthorized = () async {
        await authProvider.handleUnauthorized();
        
        if (mounted) {
          // Show snackbar notification
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate to account page (login prompt will show)
          setState(() {
            _currentIndex = 4; // Account page index (updated after adding chatbot)
          });
        }
      };
      
      // Setup callback to clear all related providers when logout
      authProvider.onLogout = () {
        // Clear CartProvider
        try {
          context.read<CartProvider>().reset();
        } catch (e) {
          print('Error clearing CartProvider: $e');
        }
        
        // Clear WishlistProvider
        try {
          context.read<WishlistProvider>().clear();
        } catch (e) {
          print('Error clearing WishlistProvider: $e');
        }
        
        // Clear UserProvider
        try {
          context.read<UserProvider>().clear();
        } catch (e) {
          print('Error clearing UserProvider: $e');
        }
        
        print('✅ All providers cleared on logout');
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
