import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'service/api_client.dart';
import 'service/auth_service.dart';
import 'service/brand_service.dart';
import 'service/cart_service.dart';
import 'service/category_service.dart';
import 'service/order_service.dart';
import 'service/product_service.dart';
import 'service/promotion_service.dart';
import 'service/review_service.dart';
import 'service/upload_service.dart';
import 'service/user_service.dart';
import 'service/wishlist_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/promotion_provider.dart';
import 'providers/review_provider.dart';
import 'providers/user_provider.dart';
import 'providers/wishlist_provider.dart';

// Constants
import 'constants/app_theme.dart';

// Pages
import 'pages/main_scaffold.dart';
import 'pages/search_page.dart';
import 'pages/cart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ApiClient - single instance
        Provider(create: (_) => ApiClient()),

        // Services - inject ApiClient
        ProxyProvider<ApiClient, AuthService>(
          update: (_, apiClient, __) => AuthService(apiClient),
        ),
        ProxyProvider<ApiClient, BrandService>(
          update: (_, apiClient, __) => BrandService(apiClient),
        ),
        ProxyProvider<ApiClient, CartService>(
          update: (_, apiClient, __) => CartService(apiClient),
        ),
        ProxyProvider<ApiClient, CategoryService>(
          update: (_, apiClient, __) => CategoryService(apiClient),
        ),
        ProxyProvider<ApiClient, OrderService>(
          update: (_, apiClient, __) => OrderService(apiClient),
        ),
        ProxyProvider<ApiClient, ProductService>(
          update: (_, apiClient, __) => ProductService(apiClient),
        ),
        ProxyProvider<ApiClient, PromotionService>(
          update: (_, apiClient, __) => PromotionService(apiClient),
        ),
        ProxyProvider<ApiClient, ReviewService>(
          update: (_, apiClient, __) => ReviewService(apiClient),
        ),
        ProxyProvider<ApiClient, UploadService>(
          update: (_, apiClient, __) => UploadService(apiClient),
        ),
        ProxyProvider<ApiClient, UserService>(
          update: (_, apiClient, __) => UserService(apiClient),
        ),
        ProxyProvider<ApiClient, WishlistService>(
          update: (_, apiClient, __) => WishlistService(apiClient),
        ),
        ChangeNotifierProxyProvider<PromotionService, PromotionProvider>(
          create: (context) => PromotionProvider(
            Provider.of<PromotionService>(context, listen: false),
          ),
          update: (_, service, previous) => previous ?? PromotionProvider(service),
        ),
        ChangeNotifierProxyProvider<ReviewService, ReviewProvider>(
          create: (context) => ReviewProvider(
            Provider.of<ReviewService>(context, listen: false),
          ),
          update: (_, service, previous) => previous ?? ReviewProvider(service),
        ),
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (context) => UserProvider(
            Provider.of<UserService>(context, listen: false),
          ),
          update: (_, service, previous) => previous ?? UserProvider(service),
        ),
        ChangeNotifierProxyProvider<WishlistService, WishlistProvider>(
          create: (context) => WishlistProvider(
            Provider.of<WishlistService>(context, listen: false),
          ),
          update: (_, service, previous) => previous ?? WishlistProvider(service),
        ),
      ],
      child: MaterialApp(
        title: 'Homi Furniture',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const MainScaffold(),
          '/search': (context) => const SearchPage(),
          '/cart': (context) => const CartPage(),
        },
      ),
    );
  }
}