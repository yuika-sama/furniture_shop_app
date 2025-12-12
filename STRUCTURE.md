# Furniture Shop App - Cấu trúc Project

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                    # Entry point
├── constants/                   # Các hằng số
│   ├── api_constants.dart       # API endpoints, storage keys
│   ├── app_colors.dart          # Định nghĩa màu sắc
│   └── app_theme.dart           # Theme configuration
│
├── models/                      # Data models
│   ├── models.dart              # Export all models
│   ├── api_response.dart        # Generic API response wrapper
│   ├── brand_model.dart         # Brand model
│   ├── cart_model.dart          # ✅ Cart, CartItem, DiscountInfo (COMPLETED)
│   ├── category_model.dart      # Category model
│   ├── order_model.dart         # ✅ Order, OrderItem, ShippingAddress (COMPLETED)
│   ├── product_model.dart       # ✅ Product, Dimensions (COMPLETED)
│   ├── promotion_model.dart     # ✅ Promotion, ValidationResult (COMPLETED)
│   ├── review_model.dart        # ✅ Review, RatingStats, ReviewsResponse (COMPLETED)
│   ├── user_model.dart          # ✅ User & AuthResponse (COMPLETED)
│   └── wishlist_model.dart      # ✅ Wishlist, WishlistResponse (COMPLETED)
│
├── service/                     # Backend services
│   ├── services.dart            # Export all services
│   ├── api_client.dart          # Dio HTTP client with interceptors
│   ├── auth_service.dart        # ✅ Authentication (COMPLETED)
│   ├── brand_service.dart       # ✅ Brands API (COMPLETED)
│   ├── order_service.dart       # ✅ Orders (COMPLETED)
│   ├── product_service.dart     # ✅ Products (COMPLETED)
│   ├── promotion_service.dart   # ✅ Promotions (COMPLETED)
│   ├── review_service.dart      # ✅ Reviews (COMPLETED)
│   ├── upload_service.dart      # ✅ Upload Cloudinary (COMPLETED)
│   ├── user_service.dart        # ✅ User Profile & Address (COMPLETED)
│   ├── wishlist_service.dart    # ✅ Wishlist/Favorites (COMPLETED)
│   ├── promotion_service.dart   # ✅ Promotions (COMPLETED)
│   ├── product_service.dart     # ✅ Products (COMPLETED)
│   ├── product_service.dart     # Products
│   ├── order_service.dart       # Orders
│   ├── review_service.dart      # Reviews
│   ├── user_service.dart        # User profile
│   └── wishlist_service.dart    # Wishlist
├── providers/                   # State management
│   ├── auth_provider.dart       # ✅ Auth state provider (COMPLETED)
│   ├── cart_provider.dart       # ✅ Cart state provider (COMPLETED)
│   ├── order_provider.dart      # ✅ Order state provider (COMPLETED)
│   └── product_provider.dart    # ✅ Product state provider (COMPLETED)
│   └── order_provider.dart      # ✅ Order state provider (COMPLETED)
│
├── pages/                       # Các trang chính
│   ├── brands_page.dart         # ✅ Danh sách brands (COMPLETED)
│   ├── login_page.dart          # ✅ Đăng nhập (COMPLETED)
│   ├── register_page.dart       # ✅ Đăng ký (COMPLETED)
│   ├── forgot_password_page.dart # ✅ Quên mật khẩu (COMPLETED)
│   ├── home_page.dart           # Trang chủ
│   ├── product_detail_page.dart # Chi tiết sản phẩm
│   ├── brand_card.dart          # ✅ Brand card widget (COMPLETED)
│   ├── cart_item_card.dart      # ✅ Cart item widget (COMPLETED)
│   ├── category_card.dart       # ✅ Category card widget (COMPLETED)
│   ├── product_card.dart        # ✅ Product card widget (COMPLETED)
│   └── custom_button.dart       # Custom buttonwidget
## 🔧 Backend API đã được map

### Wishlist Service ✅
Đã hoàn thành mapping với backend wishlist controller:

```dart
// Lấy wishlist (Requires Auth)
// Backend tự động tạo wishlist nếu chưa có
// Auto populate products với fields: name, slug, images, price, salePrice, stock, rating
final wishlistResponse = await wishlistService.getWishlist();
final wishlist = wishlistResponse.wishlist;
final count = wishlistResponse.count;

// Thêm sản phẩm vào wishlist (Requires Auth)
try {
  final response = await wishlistService.addToWishlist('product_id');
  print('Đã thêm. Wishlist có ${response.count} sản phẩm');
} catch (e) {
  // Handle errors:
  // - PRODUCT_NOT_FOUND: Sản phẩm không tồn tại
  // - ALREADY_IN_WISHLIST: Sản phẩm đã có trong wishlist
  print('Lỗi: $e');
}

// Xóa sản phẩm khỏi wishlist (Requires Auth)
try {
  final response = await wishlistService.removeFromWishlist('product_id');
  print('Đã xóa. Còn ${response.count} sản phẩm');
} catch (e) {
  // Handle errors:
  // - WISHLIST_NOT_FOUND: Chưa có wishlist
  // - PRODUCT_NOT_IN_WISHLIST: Sản phẩm không có trong wishlist
  print('Lỗi: $e');
}

// Xóa toàn bộ wishlist (Requires Auth)
final response = await wishlistService.clearWishlist();
// response.count == 0

// ========== HELPER METHODS ==========

// Toggle product (add nếu chưa có, remove nếu đã có)
final response = await wishlistService.toggleProduct('product_id');

// Check if product trong wishlist
final isInWishlist = await wishlistService.isInWishlist('product_id');
if (isInWishlist) {
  // Show filled heart icon
}

// Add multiple products
final response = await wishlistService.addMultipleToWishlist([
  'product_id_1',
  'product_id_2',
  'product_id_3',
]);

// Remove multiple products
final response = await wishlistService.removeMultipleFromWishlist([
  'product_id_1',
  'product_id_2',
]);

// Get product IDs only (lightweight)
final productIds = await wishlistService.getWishlistProductIds();
// Returns: ['id1', 'id2', 'id3']

// Get count only
final count = await wishlistService.getWishlistCount();
// Returns: 5

// Sync/refresh wishlist
final response = await wishlistService.syncWishlist();

// ========== WISHLIST MODEL HELPERS ==========

final wishlist = wishlistResponse.wishlist;

// Basic info
final count = wishlist.count; // Số sản phẩm
final isEmpty = wishlist.isEmpty;
final isNotEmpty = wishlist.isNotEmpty;

// Check product
final contains = wishlist.containsProduct('product_id');
final productIds = wishlist.productIds; // List<String>

// Value calculations
final totalValue = wishlist.totalValue; // Tổng giá sau giảm
final totalOriginalValue = wishlist.totalOriginalValue; // Tổng giá gốc
final totalSavings = wishlist.totalSavings; // Tiết kiệm được

// Stats
final avgRating = wishlist.averageRating; // Rating trung bình
final inStockCount = wishlist.inStockCount; // Số sản phẩm còn hàng
final outOfStockCount = wishlist.outOfStockCount; // Hết hàng

// Filtered lists
final onSale = wishlist.productsOnSale; // Sản phẩm đang sale
final inStock = wishlist.productsInStock; // Còn hàng
```

**Backend endpoints (All require Auth):**
- `GET /api/wishlist` - Lấy wishlist (auto create nếu chưa có)
- `POST /api/wishlist/:productId` - Thêm sản phẩm
- `DELETE /api/wishlist/:productId` - Xóa sản phẩm
- `DELETE /api/wishlist` - Xóa toàn bộ

**Features:**
- One wishlist per user (unique index)
- Auto create wishlist on first access
- Auto populate products với selected fields
- Prevent duplicate products
- Product existence validation

**WishlistModel:**
- id, user, products (List<ProductModel>)
- createdAt, updatedAt
- count, isEmpty, isNotEmpty

**Getters & Helpers:**
- `containsProduct()` - Check if product in list
- `productIds` - Get list of IDs
- `totalValue` - Sum of final prices
- `totalOriginalValue` - Sum of original prices
- `totalSavings` - Discount amount
- `averageRating` - Average of all products
- `inStockCount` / `outOfStockCount` - Stock status
- `productsOnSale` - Products with discount
- `productsInStock` - Available products

**WishlistResponse:**
- wishlist (WishlistModel)
- count (int)
- isEmpty / isNotEmpty

**Backend validation:**
- Product must exist
- Cannot add duplicate product
- Cannot remove non-existent product
- All routes require authentication

**Use cases:**
- Product detail page: Add to wishlist button
- Wishlist page: Display all favorites
- Product card: Heart icon (toggle)
- Header: Wishlist count badge
- Move to cart from wishlist

### User Service ✅
Đã hoàn thành mapping với backend user controller:

```dart
// ========== USER PROFILE ==========

// Lấy thông tin người dùng hiện tại (Requires Auth)
final user = await userService.getProfile();

// Cập nhật thông tin (Requires Auth)
final updatedUser = await userService.updateProfile(
  fullName: 'Nguyễn Văn A',
  phone: '0901234567',
  avatar: 'https://...', // optional, hoặc dùng uploadAvatar
);

// Upload avatar (Requires Auth)
final userWithAvatar = await userService.uploadAvatar(imageFile);
// Auto upload to Cloudinary và cập nhật user.avatar

// Đổi mật khẩu (Requires Auth)
await userService.changePassword(
  currentPassword: 'oldpass123',
  newPassword: 'newpass456',
);
// Requirements:
// - currentPassword phải đúng
// - newPassword phải khác currentPassword
// - newPassword ít nhất 6 ký tự

// ========== ADDRESS MANAGEMENT ==========

// Lấy danh sách địa chỉ (Requires Auth)
final addresses = await userService.getAddresses();

// Thêm địa chỉ mới (Requires Auth)
final updatedAddresses = await userService.addAddress(
  fullName: 'Nguyễn Văn A',
  phone: '0901234567',
  province: 'Hà Nội',
  district: 'Hoàn Kiếm',
  ward: 'Hàng Bạc',
  address: 'Số 123 Hàng Bạc',
  isDefault: true, // Đặt làm địa chỉ mặc định
);
// Note: Nếu isDefault = true, tất cả địa chỉ khác bị bỏ default

// Cập nhật địa chỉ (Requires Auth)
final updatedAddresses = await userService.updateAddress(
  addressId: 'address_id',
  fullName: 'Trần Thị B',
  phone: '0987654321',
  isDefault: true,
);

// Xóa địa chỉ (Requires Auth)
final remainingAddresses = await userService.deleteAddress('address_id');

// Helper: Set default address
final addresses = await userService.setDefaultAddress('address_id');

// ========== ADMIN ROUTES ==========

// Lấy tất cả users (Admin)
final response = await userService.getAllUsersAdmin(
  page: 1,
  limit: 10,
  search: 'nguyen', // Search in name, email, phone
  role: 'user', // Filter: 'user' hoặc 'admin'
  sortBy: '-createdAt',
);
// Returns: UsersResponse với users, pagination

// Lấy user theo ID (Admin)
final user = await userService.getUserByIdAdmin('user_id');

// Tạo user mới (Admin)
final newUser = await userService.createUserAdmin(
  fullName: 'Nguyễn Văn C',
  email: 'user@example.com',
  password: 'password123',
  role: 'user', // 'user' hoặc 'admin'
  phone: '0901234567',
  avatar: 'https://...',
  address: [addressModel1, addressModel2],
);

// Cập nhật user (Admin)
final updatedUser = await userService.updateUserByIdAdmin(
  userId: 'user_id',
  fullName: 'New Name',
  role: 'admin',
  password: 'newpass123', // Will be hashed
);

// Xóa user (Admin)
await userService.deleteUserByIdAdmin('user_id');

// ========== VALIDATION HELPERS ==========

final isValidPhone = userService.isValidPhone('0901234567'); // true
final isValidEmail = userService.isValidEmail('user@example.com'); // true
```

**Backend endpoints:**
- `GET /api/users/me` - Lấy profile (Auth)
- `PUT /api/users/me` - Cập nhật profile (Auth)
- `POST /api/users/me/avatar` - Upload avatar (Auth)
- `PUT /api/users/me/password` - Đổi mật khẩu (Auth)
- `GET /api/users/me/address` - Lấy địa chỉ (Auth)
- `POST /api/users/me/address` - Thêm địa chỉ (Auth)
- `PUT /api/users/me/address/:id` - Cập nhật địa chỉ (Auth)
- `DELETE /api/users/me/address/:id` - Xóa địa chỉ (Auth)
- `GET /api/admin/users` - Lấy tất cả users (Admin)
- `GET /api/admin/users/:id` - Lấy user theo ID (Admin)
- `POST /api/admin/users` - Tạo user (Admin)
- `PUT /api/admin/users/:id` - Cập nhật user (Admin)
- `DELETE /api/admin/users/:id` - Xóa user (Admin)

**Features:**
- Profile management (fullName, phone, avatar)
- Avatar upload to Cloudinary
- Password change with validation
- Address management (CRUD)
- Default address support
- Admin user management with filters
- Search by name, email, phone
- Role-based access control

**UserModel:**
- id, email, fullName, phone, role, avatar
- address (List<AddressModel>)
- createdAt, updatedAt

**Getters:**
- `isAdmin` - Check if admin role
- `displayName` - fullName or email
- `getAvatarUrl()` - Avatar URL with fallback
- `defaultAddress` - Get default address
- `hasAddresses` - Check if has addresses

**AddressModel:**
- id, fullName, phone
- province, district, ward, address
- isDefault

**Getters:**
- `fullAddress` - "Số 123, Phường Hàng Bạc, Quận Hoàn Kiếm, Hà Nội"
- `shortAddress` - Without ward

**UsersResponse (Admin):**
- users (List<UserModel>)
- page, limit, total, totalPages
- Getter: `hasMore`

**Validation:**
- Password min 6 chars
- Phone: 10 digits, starts with 0
- Email format validation
- Current password must be correct
- New password must differ from current

**Backend behavior:**
- Password auto hashed on save
- Avatar uploaded to Cloudinary
- isDefault = true auto unsets other defaults
- Address uses MongoDB subdocument array

### Upload Service ✅
Đã hoàn thành mapping với backend upload controller (Cloudinary):

```dart
// Upload single image (ADMIN only)
// Supported: jpg, jpeg, png, gif, webp
// Max size: 10MB
final result = await uploadService.uploadImage(imageFile);
// Returns: UploadResult với url, publicId, format, width, height, size

// Upload multiple images (ADMIN only)
// Max 10 images per request
final results = await uploadService.uploadMultipleImages([
  imageFile1,
  imageFile2,
  imageFile3,
]);
// Returns: List<UploadResult>

// Upload 3D model (ADMIN only)
// Supported: glb, gltf, obj, fbx, usdz
// Max size: 50MB
final result = await uploadService.upload3DModel(modelFile);
// Returns: Upload3DResult với url, publicId, format, resourceType, size

// Delete single file (ADMIN only)
await uploadService.deleteFile(
  publicId: 'furniture/product_123',
  resourceType: 'image', // image, raw, video
);

// Delete multiple files (ADMIN only)
final result = await uploadService.deleteMultipleFiles(
  publicIds: ['id1', 'id2', 'id3'],
  resourceType: 'image',
);
// Returns: DeleteMultipleResult với total, success, failed, details

// Helper: Upload product images
final imageUrls = await uploadService.uploadProductImages([
  imageFile1,
  imageFile2,
]);
// Returns: List<String> URLs

// Helper: Delete product images
await uploadService.deleteProductImages([
  'https://res.cloudinary.com/.../image1.jpg',
  'https://res.cloudinary.com/.../image2.jpg',
]);
// Auto extract publicIds from URLs

// Validate image before upload
final isValid = await uploadService.validateImageFile(
  imageFile,
  maxSizeInMB: 10,
);
```

**Backend endpoints (Admin only):**
- `POST /api/upload/image` - Upload single image
- `POST /api/upload/images` - Upload multiple images (max 10)
- `POST /api/upload/3d-model` - Upload 3D model file
- `DELETE /api/upload/delete` - Delete single file
- `DELETE /api/upload/delete-multiple` - Delete multiple files

**Features:**
- Upload to Cloudinary cloud storage
- Support multiple image formats (jpg, jpeg, png, gif, webp)
- Support 3D model formats (glb, gltf, obj, fbx, usdz)
- File size validation (10MB for images, 50MB for 3D)
- Batch upload (max 10 images)
- Batch delete with success tracking
- Auto extract publicId from Cloudinary URLs
- Helper methods for product images

**Models:**
- `UploadResult` - Image upload result (url, publicId, format, dimensions, size)
- `Upload3DResult` - 3D model upload result (url, publicId, format, resourceType, size)
- `DeleteMultipleResult` - Batch delete result (total, success, failed, successRate)

**Helpers:**
- `sizeText` - Format size as KB/MB
- `dimensionsText` - Format as "1920x1080"
- `successRate` - Calculate delete success percentage
- `extractPublicIdFromUrl()` - Parse Cloudinary URL to get publicId

**Validation:**
- File existence check
- File size limit
- File extension check
- Max 10 images for batch upload

**Security:**
- All upload endpoints require Admin role
- Token authentication via Bearer header

### Review Service ✅
### Review Service ✅
Đã hoàn thành mapping với backend review controller:

```dart
// Lấy đánh giá theo sản phẩm (PUBLIC)
// Auto populate: user (fullName, avatar)
// Includes: pagination, ratingStats
final response = await reviewService.getReviewsByProduct(
  'product_id',
  page: 1,
  limit: 10,
  rating: 5, // optional: filter by rating (1-5)
  sortBy: '-createdAt', // -createdAt, createdAt, -rating, rating
);

// response.reviews - List<ReviewModel>
// response.ratingStats - List<RatingStats> với rating distribution
// response.pagination - page, limit, total, totalPages

// Tạo đánh giá (USER - Requires Auth)
// Requirements:
// - User phải đã mua sản phẩm (order status = delivered)
// - Mỗi user chỉ review 1 lần cho 1 sản phẩm
final review = await reviewService.createReview(
  productId: 'product_id',
  rating: 5, // 1-5
  comment: 'Sản phẩm rất tốt!',
);

// Cập nhật đánh giá (USER - Requires Auth)
// Chỉ user sở hữu mới được update
final updatedReview = await reviewService.updateReview(
  reviewId: 'review_id',
  rating: 4,
  comment: 'Cập nhật đánh giá',
);

// Xóa đánh giá (USER - Requires Auth)
// Chỉ user sở hữu mới được xóa
await reviewService.deleteReview('review_id');

// ADMIN: Lấy tất cả đánh giá
final response = await reviewService.getAllReviewsAdmin(
  page: 1,
  limit: 20,
  rating: 5, // optional
  productId: 'product_id', // optional
  userId: 'user_id', // optional
  search: 'query', // search in comment
  sortBy: '-createdAt',
);

// ADMIN: Xóa đánh giá
await reviewService.adminDeleteReview('review_id');
```

**Backend endpoints:**
- `GET /api/reviews/product/:productId` - Lấy reviews theo sản phẩm (PUBLIC)
- `POST /api/reviews` - Tạo review (User, requires purchase)
- `PUT /api/reviews/:id` - Cập nhật review (User, owner only)
- `DELETE /api/reviews/:id` - Xóa review (User, owner only)
- `GET /api/admin/reviews` - Lấy tất cả (Admin, filters + pagination)
- `DELETE /api/admin/reviews/:id` - Xóa review (Admin)

**Features:**
- One review per user per product (unique index)
- Only purchased products can be reviewed (status = delivered)
- Auto update product rating when review created/updated/deleted
- Rating statistics (count by rating 1-5)
- Populate user info (fullName, avatar)
- Populate product info (name, slug, images)
- Search in comment content
- Filter by rating, product, user

**ReviewModel:**
- id, product, user
- rating (1-5), comment
- createdAt, updatedAt
- userDetails (ReviewUser with fullName, avatar)
- productDetails (ReviewProduct with name, slug, images)

**Getters:**
- `userName`, `userAvatar` - User info
- `productName`, `productSlug`, `productImage` - Product info
- `timeAgoText` - "2 ngày trước", "3 giờ trước"
- `isEdited` - Check if edited (updatedAt > createdAt)

**RatingStats:**
- rating (1-5)
- count (number of reviews)
- Helpers: getCountByRating(), getPercentageByRating(), averageRating

**Backend validation:**
- Product must exist
- User must have purchased product (delivered order)
- One review per user per product
- Rating must be 1-5
- Comment is required

### Promotion Service ✅ợc map

### Promotion Service ✅
Đã hoàn thành mapping với backend promotion controller:

```dart
// Lấy tất cả promotions đang hoạt động (PUBLIC)
// Backend auto filter: isActive=true, startDate<=now, endDate>=now
final result = await promotionService.getAllPromotions();

// Validate promotion code (PUBLIC)
final result = await promotionService.validatePromotionCode(
  code: 'SUMMER2023',
  orderAmount: 1500000, // optional
);

// Response khi valid:
// {
//   "success": true,
//   "valid": true,
//   "message": "Mã khuyến mãi hợp lệ",
//   "promotion": { ... },
//   "discountAmount": 300000  // Nếu có orderAmount
// }

// Response khi invalid:
// {
//   "success": false,
//   "valid": false,
//   "message": "Mã khuyến mãi đã hết hạn"
// }

// Helper: Apply promotion code
final result = await promotionService.applyPromotionCode(
  code: 'SUMMER2023',
  orderAmount: 1500000,
);

// ADMIN: Lấy tất cả promotions
final result = await promotionService.getAllPromotionsAdmin(
  page: 1,
  limit: 20,
  isActive: true,
  search: 'SUMMER',
  sortBy: '-createdAt',
);

// ADMIN: Tạo promotion mới
final result = await promotionService.createPromotion(
  code: 'SUMMER2023',
  description: 'Giảm 20% cho đơn hàng từ 1 triệu',
  discountType: DiscountType.percentage, // hoặc DiscountType.fixed
  discountValue: 20,
  startDate: DateTime(2023, 6, 1),
  endDate: DateTime(2023, 8, 31),
  minSpend: 1000000,
  isActive: true,
);

// ADMIN: Cập nhật promotion
final result = await promotionService.updatePromotion(
  promotionId: 'promotion_id',
  discountValue: 25,
  isActive: false,
);

// ADMIN: Xóa promotion
final result = await promotionService.deletePromotion('promotion_id');
```

**Backend endpoints:**
- `GET /api/promotions` - Lấy promotions đang active (PUBLIC)
- `POST /api/promotions/validate` - Validate code (PUBLIC)
- `GET /api/admin/promotions` - Lấy tất cả (Admin, filters + pagination)
- `GET /api/admin/promotions/:id` - Lấy theo ID (Admin)
- `POST /api/admin/promotions` - Tạo mới (Admin)
- `PUT /api/admin/promotions/:id` - Cập nhật (Admin)
- `DELETE /api/admin/promotions/:id` - Xóa (Admin)

**Features:**
- Validate promotion code với order amount
- Tự động tính discount amount (percentage hoặc fixed)
- Check minSpend requirement
- Check date range (startDate - endDate)
- Support 2 discount types: percentage (0-100%), fixed (amount)
- Admin CRUD với filters và search
- Statistics (active count, total count)

**PromotionModel:**
- code (uppercase, unique)
- description
- discountType (percentage/fixed)
- discountValue
- startDate, endDate
- minSpend (default 0)
- isActive

**Getters:**
- `isValid` - Còn hiệu lực không
- `isExpired` - Đã hết hạn
- `isUpcoming` - Chưa bắt đầu
- `calculateDiscount(orderAmount)` - Tính discount
- `discountText` - Text hiển thị (20% hoặc 100000đ)
- `dateRangeText` - Khoảng thời gian
- `daysRemaining` - Số ngày còn lại

### Product Service ✅
### Product Service ✅
Đã hoàn thành mapping với backend product controller:

```dart
// Lấy danh sách sản phẩm với filters
final result = await productService.getAllProducts(
  category: 'category_id', // Auto include subcategories
  brand: 'brand_id',
  minPrice: 100000,
  maxPrice: 5000000,
  search: 'sofa',
  sort: 'best-seller', // newest, oldest, price-asc, price-desc, name-asc, name-desc, rating
  page: 1,
  limit: 10,
);

// Lấy sản phẩm theo slug
final result = await productService.getProductBySlug('sofa-goc-luxury');

// Lấy sản phẩm nổi bật (isFeatured = true)
final result = await productService.getFeaturedProducts(limit: 8);

// Lấy sản phẩm mới (sort by createdAt desc)
final result = await productService.getNewArrivals(limit: 8);

// Lấy sản phẩm bán chạy (sort by soldCount desc)
final result = await productService.getBestSellers(limit: 8);

// Lấy sản phẩm liên quan (same category, brand, tags)
final result = await productService.getRelatedProducts(
  productId: 'product_id',
  limit: 4,
);

// ADMIN: Tạo sản phẩm mới
final result = await productService.createProduct(
  name: 'Sofa góc chữ L',
  sku: 'SOFA-001',
  description: 'Mô tả chi tiết...',
  price: 10000000,
  originalPrice: 15000000,
  category: 'category_id',
  brand: 'brand_id',
  stock: 50,
  images: ['image1.jpg', 'image2.jpg'],
  dimensions: Dimensions(width: 200, height: 80, length: 150),
  colors: ['Nâu', 'Xám'],
  materials: ['Gỗ sồi', 'Vải nhung'],
  tags: ['sofa', 'living-room'],
  isFeatured: true,
);

// ADMIN: Cập nhật sản phẩm
final result = await productService.updateProduct(
  productId: 'product_id',
  price: 9500000,
  stock: 45,
);
```

**Backend endpoints:**
- `GET /api/products` - Lấy danh sách (filters: category, brand, price, search, sort)
- `GET /api/products/:slug` - Lấy theo slug
- `GET /api/products/featured` - Sản phẩm nổi bật
- `GET /api/products/new-arrivals` - Sản phẩm mới
- `GET /api/products/best-sellers` - Bán chạy
- `GET /api/products/related/:productId` - Sản phẩm liên quan
- `GET /api/admin/products/:id` - Lấy theo ID (Admin)
- `POST /api/admin/products` - Tạo mới (Admin)
- `PUT /api/admin/products/:id` - Cập nhật (Admin)
- `DELETE /api/admin/products/:id` - Xóa (Admin)

**Features:**
- Filter theo category (auto include subcategories)
- Filter theo brand, price range, search
- Multiple sort options (price, name, rating, soldCount, createdAt)
- Pagination đầy đủ
- Product dimensions, colors, materials
- Average rating & total reviews
- Stock management với soldCount
- 3D model support (model3DUrl)
- Featured products flag
- Related products by category/brand/tags

### Order Service ✅
### Order Service ✅
Đã hoàn thành mapping với backend order controller:

```dart
// Tạo đơn hàng mới (từ giỏ hàng)
final result = await orderService.createOrder(
  shippingAddress: ShippingAddress(
    fullName: 'Nguyễn Văn A',
    phone: '0123456789',
    province: 'Hà Nội',
    district: 'Cầu Giấy',
    ward: 'Dịch Vọng',
    address: 'Số 123 đường ABC',
  ),
  paymentMethod: PaymentMethod.cod, // hoặc PaymentMethod.bank
  transactionId: 'TXN123', // required nếu BANK
  discountCode: 'SUMMER2023', // optional
  notes: 'Giao giờ hành chính', // optional
);

// Lấy đơn hàng của user
final result = await orderService.getMyOrders(
  status: OrderStatus.pending,
  page: 1,
  limit: 10,
);

// Tra cứu đơn hàng theo code (PUBLIC, không cần auth)
final result = await orderService.getOrderByCode('ORD-20231212-ABCD');

// Hủy đơn hàng (chỉ pending/processing)
final result = await orderService.cancelOrder('order_id');

// ADMIN: Thống kê đơn hàng
final result = await orderService.getOrderStats(
  startDate: DateTime(2023, 1, 1),
  endDate: DateTime(2023, 12, 31),
);
```

**Backend endpoints:**
- `POST /api/orders` - Tạo đơn hàng từ giỏ hàng (Protected)
- `GET /api/orders` - Lấy đơn hàng của user (Protected, filter by status)
- `GET /api/orders/:id` - Lấy chi tiết đơn hàng (Protected)
- `GET /api/orders/code/:code` - Tra cứu theo mã (PUBLIC)
- `PUT /api/orders/:id/cancel` - Hủy đơn hàng (Protected)
- `GET /api/admin/orders` - Lấy tất cả đơn hàng (Admin)
- `PUT /api/admin/orders/:id/status` - Cập nhật trạng thái (Admin)
- `PUT /api/admin/orders/:id/payment-status` - Cập nhật thanh toán (Admin)
- `GET /api/admin/orders/stats` - Thống kê (Admin)

**Features:**
- Tạo order từ cart với validation đầy đủ
- Snapshot product info (name, price, image)
- Apply discount code tự động
- Support 2 payment methods: COD, BANK
- Order status: pending → processing → shipped → delivered
- Cancel order với hoàn stock
- Public order tracking by code
- Admin statistics (revenue, best selling)

### Category Service ✅
### Category Service ✅
Đã hoàn thành mapping với backend category controller:

```dart
// Lấy tất cả categories
final result = await categoryService.getAllCategories(
  page: 1,
  limit: 20,
  search: 'living',
  parent: 'null', // filter root categories
);

// Lấy cấu trúc cây categories (với children nested)
final result = await categoryService.getCategoryTree();

// Lấy category theo slug
final result = await categoryService.getCategoryBySlug('living-room');

// Helper: Lấy root categories (không có parent)
final result = await categoryService.getRootCategories();

// Helper: Lấy subcategories của parent
final result = await categoryService.getSubcategories(
  parentId: 'category_id',
);

// Helper: Lấy categories phổ biến
final result = await categoryService.getPopularCategories(limit: 10);
```

**Backend endpoints:**
- `GET /api/categories` - Lấy tất cả (page, limit, search, parent)
- `GET /api/categories/tree` - Cấu trúc cây với children nested
- `GET /api/categories/:slug` - Lấy category theo slug

**Features:**
- Support parent-child relationship (subcategories)
- Tree structure view
- Filter by parent category
- ProductCount cho mỗi category
- Pagination & search

### Cart Service ✅
### Cart Service ✅
Đã hoàn thành mapping với backend cart controller (Protected routes):

```dart
// Lấy giỏ hàng
final result = await cartService.getCart();

// Thêm sản phẩm vào giỏ
final result = await cartService.addToCart(
  productId: 'product_id',
  quantity: 2,
);

// Cập nhật số lượng
final result = await cartService.updateCartItem(
  productId: 'product_id',
  quantity: 3,
);

// Xóa sản phẩm
final result = await cartService.removeCartItem(
  productId: 'product_id',
);

// Xóa toàn bộ giỏ hàng
final result = await cartService.clearCart();

// Áp dụng mã giảm giá
final result = await cartService.applyDiscount(
  code: 'SALE10',
);

// Gỡ mã giảm giá
final result = await cartService.removeDiscount();

// Helper methods
await cartService.incrementItem(...);
await cartService.decrementItem(...);
```

**Backend endpoints (All Protected):**
- `GET /api/cart` - Lấy giỏ hàng
- `POST /api/cart/items` - Thêm sản phẩm (productId, quantity)
- `PUT /api/cart/items/:productId` - Cập nhật quantity
- `DELETE /api/cart/items/:productId` - Xóa sản phẩm
- `DELETE /api/cart` - Xóa toàn bộ giỏ
- `POST /api/cart/discount` - Áp dụng mã giảm giá (code)
- `DELETE /api/cart/discount` - Gỡ mã giảm giá

**Features:**
- Auto validate stock khi lấy giỏ hàng
- Auto update price nếu thay đổi
- Calculate subTotal, discount, totalAmount
- Support promotion codes
- Real-time cart updates

### Auth Service ✅
Đã hoàn thành mapping với backend auth controller:

```dart
// Đăng ký
final result = await authService.register(
  email: 'user@example.com',
  password: 'password123',
  fullName: 'John Doe',
  phone: '0123456789', // optional
);

// Đăng nhập
final result = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Lấy thông tin user hiện tại (Protected route)
final result = await authService.getMe();

// Quên mật khẩu
final result = await authService.forgotPassword(
  email: 'user@example.com',
);

// Đặt lại mật khẩu
final result = await authService.resetPassword(
  token: 'reset_token_from_email',
  newPassword: 'newPassword123',
);

// Đăng xuất
await authService.logout();

// Kiểm tra đăng nhập
final isLoggedIn = await authService.isLoggedIn();
final isAdmin = await authService.isAdmin();
```

**Backend endpoints:**
- `POST /api/auth/register` - Đăng ký (email, password, fullName, phone)
- `POST /api/auth/login` - Đăng nhập (email, password)
- `GET /api/auth/me` - Lấy thông tin user (cần token)
- `POST /api/auth/forgot-password` - Quên mật khẩu (email)
- `POST /api/auth/reset-password` - Đặt lại mật khẩu (token, newPassword)

**Middleware & Token:**
- Token được lưu trong `FlutterSecureStorage`
- Tự động thêm `Authorization: Bearer <token>` vào headers
- Nếu 401 Unauthorized → tự động xóa token & redirect login

### Brand Service ✅
Đã hoàn thành mapping với backend:

```dart
// Lấy tất cả brands (có phân trang & tìm kiếm)
final result = await brandService.getAllBrands(
  page: 1,
  limit: 20,
  search: 'ikea',
);

// Lấy brands phổ biến
final result = await brandService.getPopularBrands(limit: 10);

// Lấy brand theo slug
final result = await brandService.getBrandBySlug('ikea');
```

**Response format:**
```dart
{
  'success': true,
  'brands': List<BrandModel>,
## 📝 TODO

### Services cần implement tiếp:
- [x] ✅ CategoryService - get all, tree, by slug (COMPLETED)
- [x] ✅ ProductService - CRUD products, filters, search (COMPLETED)
- [x] ✅ AuthService - login, register, logout, forgot password
- [x] ✅ CartService - add, remove, update cart, discount (COMPLETED)
- [x] ✅ OrderService - create, track, cancel orders (COMPLETED)
- [x] ✅ PromotionService - validate, CRUD promotions (COMPLETED)
- [x] ✅ ReviewService - product reviews, rating stats (COMPLETED)
- [x] ✅ UploadService - Cloudinary upload/delete (COMPLETED)
- [x] ✅ UserService - profile, password, address management (COMPLETED)
- [x] ✅ WishlistService - favorites management (COMPLETED)

### Pages đã có:
- [x] ✅ LoginPage - Form đăng nhập đầy đủ
- [x] ✅ RegisterPage - Form đăng ký (email, password, fullName, phone)
- [x] ✅ ForgotPasswordPage - Quên mật khẩu với UI success state
- [x] ✅ BrandsPage - Grid brands với search & filter
- [x] ✅ CategoriesPage - Grid/Tree view categories (COMPLETED)
- [x] ✅ CartPage - Giỏ hàng đầy đủ (COMPLETED)
- [x] ✅ MyOrdersPage - Danh sách đơn hàng với tabs (COMPLETED)
- [x] ✅ OrderDetailPage - Chi tiết đơn hàng (COMPLETED)
- [x] ✅ OrderTrackingPage - Tra cứu đơn public (COMPLETED)

### Pages cần implement:
- [ ] HomePage - featured products, categories
- [ ] CategoryPage - products by category
- [ ] ProductDetailPage - product info, reviews
- [ ] CheckoutPage - order checkout
- [ ] ProfilePage - user profile
- [ ] OrderHistoryPage - past orders
- [ ] ResetPasswordPage - Form nhập mật khẩu mới (từ email link)
App sử dụng màu nâu chủ đạo phù hợp với furniture shop:
- Primary: `#6B4E3D` (Nâu gỗ)
- Secondary: `#F5E6D3` (Beige)
- Accent: `#D4A574` (Vàng gold)

## 🚀 Sử dụng

### Import models
```dart
import 'package:furniture_shop_app/models/models.dart';
```

### Import services
```dart
import 'package:furniture_shop_app/service/services.dart';
```

### Khởi tạo service
```dart
final apiClient = ApiClient();
final brandService = BrandService(apiClient);
```

### Gọi API
```dart
final result = await brandService.getAllBrands();
if (result['success'] == true) {
  final brands = result['brands'] as List<BrandModel>;
  // Use brands...
}
```

## 📝 TODO

### Services cần implement tiếp:
- [ ] CategoryService - tương tự BrandService
- [ ] ProductService - CRUD products
- [ ] AuthService - login, register, logout
- [ ] CartService - add, remove, update cart
- [ ] OrderService - create, track orders
- [ ] ReviewService - product reviews
- [ ] UserService - profile management
- [ ] WishlistService - favorites

### Pages cần implement:
- [ ] HomePage - featured products, categories
- [ ] CategoryPage - products by category
- [ ] ProductDetailPage - product info, reviews
- [ ] CartPage - shopping cart
- [ ] CheckoutPage - order checkout
- [ ] ProfilePage - user profile
- [ ] OrderHistoryPage - past orders

### Components cần tạo:
- [ ] ProductCard - hiển thị sản phẩm
- [ ] CategoryCard - hiển thị category
- [ ] ReviewCard - hiển thị đánh giá
- [ ] EmptyState - trạng thái rỗng
- [ ] LoadingWidget - loading indicator

## 🔑 API Configuration

Backend URL được config trong `ApiClient`:
```dart
String baseUrl = "https://furniture-shop-backend.vercel.app";
## 🔐 Authentication Flow

### 1. Login Flow
```
LoginPage → AuthService.login() → Save token to SecureStorage → Navigate to Home
```

### 2. Register Flow
```
RegisterPage → AuthService.register() → Save token to SecureStorage → Navigate to Home
```

### 3. Protected Routes
```
Any Page → API Call → ApiClient Interceptor → Add Bearer token → Backend validates
```

### 4. Token Expired (401)
```
API Response 401 → ApiClient Interceptor → Delete token → Redirect to Login
```

### 5. Forgot Password Flow
```
ForgotPasswordPage → AuthService.forgotPassword() → Email sent → User clicks link in email
→ ResetPasswordPage → AuthService.resetPassword() → Success → Login
```

## 📦 State Management

### AuthProvider (ChangeNotifier)
Quản lý global auth state:
```dart
// Sử dụng với Provider
Provider.of<AuthProvider>(context).currentUser
Provider.of<AuthProvider>(context).isLoggedIn
Provider.of<AuthProvider>(context).isAdmin
```

## 🛠 Dependencies cần cài

Trong `pubspec.yaml`:
```yaml
dependencies:
  dio: ^5.4.0                    # HTTP client
  flutter_secure_storage: ^9.0.0 # Secure token storage
  provider: ^6.1.0               # State management
```

Run:
```bash
flutter pub get
```io: ^5.4.0                    # HTTP client
  flutter_secure_storage: ^9.0.0 # Secure token storage
```

Run:
```bash
flutter pub get
```
