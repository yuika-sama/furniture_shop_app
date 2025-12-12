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
import 'providers/promotion_provider.dart';
import 'providers/review_provider.dart';
import 'providers/user_provider.dart';
import 'providers/wishlist_provider.dart';

// Test Pages
import 'pages/test_api_page.dart';

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

        // Providers - inject services
        ChangeNotifierProxyProvider<PromotionService, PromotionProvider>(
          create: (context) => PromotionProvider(
            Provider.of<PromotionService>(context, listen: false),
          ),
          update: (context, promoService, previous) =>
          previous ?? PromotionProvider(promoService),
        ),
        ChangeNotifierProxyProvider<ReviewService, ReviewProvider>(
          create: (context) => ReviewProvider(
            Provider.of<ReviewService>(context, listen: false),
          ),
          update: (context, reviewService, previous) =>
          previous ?? ReviewProvider(reviewService),
        ),
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (context) => UserProvider(
            Provider.of<UserService>(context, listen: false),
          ),
          update: (context, userService, previous) =>
          previous ?? UserProvider(userService),
        ),
        ChangeNotifierProxyProvider<WishlistService, WishlistProvider>(
          create: (context) => WishlistProvider(
            Provider.of<WishlistService>(context, listen: false),
          ),
          update: (context, wishlistService, previous) =>
          previous ?? WishlistProvider(wishlistService),
        ),
      ],
      child: MaterialApp(
        title: 'Furniture Shop - API Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const TestApiPage(),
        },
      ),
    );
  }
}