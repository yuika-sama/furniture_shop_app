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
import 'providers/category_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/promotion_provider.dart';
import 'providers/review_provider.dart';
import 'providers/user_provider.dart';
import 'providers/wishlist_provider.dart';

// Constants
import 'constants/app_theme.dart';

// Components
import 'components/error_boundary.dart';

// Pages
import 'pages/main_scaffold.dart';
import 'pages/search_page.dart';
import 'pages/cart_page.dart';

void main() {
  // Bắt tất cả errors trong Flutter framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };

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

        // Providers - State Management
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (_) => AuthProvider(AuthService(ApiClient())),
          update: (_, service, previous) => previous ?? AuthProvider(service),
        ),
        
        ChangeNotifierProxyProvider<CategoryService, CategoryProvider>(
          create: (_) => CategoryProvider(categoryService: CategoryService(ApiClient())),
          update: (_, service, previous) => previous ?? CategoryProvider(categoryService: service),
        ),
        ChangeNotifierProxyProvider<ProductService, ProductProvider>(
          create: (_) => ProductProvider(productService: ProductService(ApiClient())),
          update: (_, service, previous) => previous ?? ProductProvider(productService: service),
        ),
        ChangeNotifierProxyProvider<PromotionService, PromotionProvider>(
          create: (_) => PromotionProvider(PromotionService(ApiClient())),
          update: (_, service, previous) => previous ?? PromotionProvider(service),
        ),
        ChangeNotifierProxyProvider<ReviewService, ReviewProvider>(
          create: (_) => ReviewProvider(ReviewService(ApiClient())),
          update: (_, service, previous) => previous ?? ReviewProvider(service),
        ),
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (_) => UserProvider(UserService(ApiClient())),
          update: (_, service, previous) => previous ?? UserProvider(service),
        ),
        ChangeNotifierProxyProvider<WishlistService, WishlistProvider>(
          create: (_) => WishlistProvider(WishlistService(ApiClient())),
          update: (_, service, previous) => previous ?? WishlistProvider(service),
        ),
        ChangeNotifierProxyProvider<OrderService, OrderProvider>(
          create: (_) => OrderProvider(orderService: OrderService(ApiClient())),
          update: (_, orderService, previous) =>
              previous ?? OrderProvider(orderService: orderService),
        ),
        
        ChangeNotifierProxyProvider2<CartService, AuthProvider, CartProvider>(
          create: (_) => CartProvider(
            cartService: CartService(ApiClient()),
          ),
          update: (_, cartService, authProvider, previous) =>
              previous ?? CartProvider(cartService: cartService, authProvider: authProvider),
        ),
      ],
      child: ErrorBoundary(
        child: Builder(
          builder: (context) {
            return MaterialApp(
              title: 'Homi Furniture',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              initialRoute: '/',
              routes: {
                '/': (context) => const MainScaffold(),
                '/search': (context) => const SearchPage(),
                '/cart': (context) => const CartPage(),
              },
              // Error handling cho navigation
              onUnknownRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => ErrorBoundary.buildErrorScreen(
                    context: context,
                    title: 'Không tìm thấy trang',
                    message: 'Trang "${settings.name}" không tồn tại',
                    onRetry: () => Navigator.of(context).pushReplacementNamed('/'),
                  ),
                );
              },
              // Global error builder
              builder: (context, widget) {
                ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                  return ErrorBoundary.buildErrorScreen(
                    context: context,
                    title: 'Lỗi ứng dụng',
                    message: 'Đã xảy ra lỗi không mong muốn',
                    onRetry: () {
                      // Trigger rebuild
                      (context as Element).markNeedsBuild();
                    },
                  );
                };
                return widget!;
              },
            );
          },
        ),
      ),
    );
  }
}
