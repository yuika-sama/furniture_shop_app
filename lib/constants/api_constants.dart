// Constants
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://furniture-shop-backend.vercel.app';
  static const String localUrl = 'http://localhost:5000';
  
  // API Endpoints
  static const String apiPrefix = '/api';
  
  // Brands
  static const String brands = '$apiPrefix/brands';
  static const String popularBrands = '$brands/popular';
  
  // Categories
  static const String categories = '$apiPrefix/categories';
  static const String popularCategories = '$categories/popular';
  
  // Products
  static const String products = '$apiPrefix/products';
  static const String featuredProducts = '$products/featured';
  static const String newProducts = '$products/new';
  
  // Auth
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String logout = '$apiPrefix/auth/logout';
  
  // User Profile
  static const String users = '$apiPrefix/users';
  static const String userProfile = '$users/me';
  static const String userAvatar = '$users/me/avatar';
  static const String userPassword = '$users/me/password';
  static const String userAddress = '$users/me/address';
  static const String adminUsers = '$apiPrefix/admin/users';
  
  // Cart
  static const String cart = '$apiPrefix/cart';
  
  // Wishlist (Auth required)
  static const String wishlist = '$apiPrefix/wishlist';
  
  // Orders
  static const String orders = '$apiPrefix/orders';
  static const String adminOrders = '$apiPrefix/admin/orders';
  
  // Reviews
  static const String reviews = '$apiPrefix/reviews';
  static const String adminReviews = '$apiPrefix/admin/reviews';
  
  // Promotions
  static const String promotions = '$apiPrefix/promotions';
  static const String adminPromotions = '$apiPrefix/admin/promotions';
  
  // Upload (Admin only)
  static const String upload = '$apiPrefix/upload';
  static const String uploadImage = '$upload/image';
  static const String uploadImages = '$upload/images';
  static const String upload3DModel = '$upload/3d-model';
  static const String uploadDelete = '$upload/delete';
  static const String uploadDeleteMultiple = '$upload/delete-multiple';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
}
