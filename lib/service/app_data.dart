const String appKnowledgeBase = '''
# Tài Liệu Dữ Liệu Nguồn - Ứng Dụng Furniture Shop (Homi Furniture)

## Tổng Quan Ứng Dụng

**Homi Furniture** là ứng dụng thương mại điện tử bán nội thất được xây dựng bằng Flutter. Ứng dụng kết nối với backend qua REST API và cung cấp đầy đủ chức năng mua sắm trực tuyến.

### Thông Tin Kỹ Thuật
- **Framework**: Flutter (Dart)
- **Architecture**: Provider Pattern (State Management)
- **Backend API**: https://furniture-shop-backend.vercel.app
- **API Prefix**: /api

---

## Cấu Trúc Dự Án

```
lib/
├── components/           # Các component UI tái sử dụng (8 files)
├── constants/           # Hằng số và cấu hình (2 files)
├── models/              # Data models (11 files)
├── pages/               # Các màn hình UI (20 files)
├── providers/           # State management (9 files)
├── service/             # API services (16 files)
├── utils/               # Tiện ích
└── main.dart            # Entry point
```

---

## Models (Mô Hình Dữ Liệu)

### 1. ProductModel (Sản Phẩm)
**File**: `lib/models/product_model.dart`

#### Thuộc tính chính:
- `id`: ID sản phẩm
- `name`: Tên sản phẩm
- `slug`: URL-friendly name
- `sku`: Mã sản phẩm
- `description`: Mô tả
- `price`: Giá hiện tại
- `originalPrice`: Giá gốc (trước khi giảm)
- `images`: Danh sách ảnh sản phẩm
- `model3DUrl`: URL mô hình 3D (nếu có)
- `categoryId`, `category`: Danh mục sản phẩm
- `brandId`, `brand`: Thương hiệu
- `stock`: Số lượng tồn kho
- `soldCount`: Số lượng đã bán
- `dimensions`: Kích thước (width, height, length)
- `colors`: Danh sách màu sắc
- `materials`: Danh sách chất liệu
- `tags`: Các tag
- `averageRating`: Đánh giá trung bình
- `totalReviews`: Tổng số đánh giá
- `isFeatured`: Sản phẩm nổi bật

#### Getters hữu ích:
- `hasDiscount`: Có giảm giá không
- `discountPercent`: % giảm giá
- `savedAmount`: Số tiền tiết kiệm
- `inStock`, `lowStock`, `outOfStock`: Trạng thái tồn kho
- `primaryImage`: Ảnh đầu tiên
- `categoryName`, `brandName`: Tên danh mục/thương hiệu
- `ratingText`, `reviewsText`: Text hiển thị đánh giá

---

### 2. UserModel (Người Dùng)
**File**: `lib/models/user_model.dart`

#### Thuộc tính chính:
- `id`: ID người dùng
- `email`: Email
- `fullName`: Họ tên
- `phone`: Số điện thoại
- `role`: Vai trò ('user' hoặc 'admin')
- `avatar`: URL ảnh đại diện
- `address`: Danh sách địa chỉ giao hàng

#### Getters hữu ích:
- `isAdmin`: Kiểm tra admin
- `displayName`: Tên hiển thị
- `defaultAddress`: Địa chỉ mặc định
- `hasAddresses`: Có địa chỉ không

---

### 3. CartModel (Giỏ Hàng)
**File**: `lib/models/cart_model.dart`

#### Thuộc tính chính:
- `id`: ID giỏ hàng
- `userId`: ID người dùng
- `items`: Danh sách CartItem
- `subTotal`: Tổng tiền trước giảm giá
- `discount`: Thông tin giảm giá
- `totalAmount`: Tổng tiền sau giảm giá

#### Getters hữu ích:
- `itemCount`: Số loại sản phẩm
- `totalItems`: Tổng số sản phẩm (tính cả quantity)
- `isEmpty`, `isNotEmpty`: Trạng thái giỏ hàng
- `savings`: Số tiền tiết kiệm
- `finalPrice`: Giá cuối cùng

---

### 4. OrderModel (Đơn Hàng)
**File**: `lib/models/order_model.dart`

#### OrderStatus (Trạng thái đơn hàng):
- `pending`: Chờ xác nhận
- `processing`: Đang xử lý
- `shipped`: Đang giao
- `delivered`: Đã giao
- `cancelled`: Đã hủy

#### PaymentInfo (Thanh toán):
- `method`: COD hoặc BANK
- `status`: pending, completed, failed

---

### 5. CategoryModel (Danh Mục)
**File**: `lib/models/category_model.dart`

#### Thuộc tính chính:
- `id`: ID danh mục
- `name`: Tên danh mục
- `slug`: URL slug
- `image`: Ảnh danh mục
- `parentCategoryId`: ID danh mục cha
- `productCount`: Số sản phẩm
- `children`: Danh sách danh mục con

---

### 6. PromotionModel (Khuyến Mãi)
**File**: `lib/models/promotion_model.dart`

#### Thuộc tính chính:
- `code`: Mã giảm giá
- `discountType`: percentage (%) hoặc fixed (số tiền)
- `discountValue`: Giá trị giảm
- `startDate`, `endDate`: Thời gian hiệu lực
- `minSpend`: Đơn hàng tối thiểu

---

### 7. ReviewModel (Đánh Giá)
**File**: `lib/models/review_model.dart`

#### Thuộc tính chính:
- `product`: ID sản phẩm
- `user`: ID người dùng
- `rating`: Điểm đánh giá (1-5)
- `comment`: Nội dung

---

## Services (API Services)

### 1. ProductService
- `getAllProducts()`: Lấy danh sách sản phẩm với filter
- `getProductBySlug(slug)`: Chi tiết sản phẩm
- `getFeaturedProducts()`: Sản phẩm nổi bật
- `getNewArrivals()`: Sản phẩm mới
- `getBestSellers()`: Bán chạy
- `searchProducts(keyword)`: Tìm kiếm sản phẩm

### 2. AuthService
- `login(email, password)`: Đăng nhập
- `register(email, password, fullName, phone)`: Đăng ký
- `logout()`: Đăng xuất

### 3. CartService
- `getCart()`: Lấy giỏ hàng
- `addToCart(productId, quantity)`: Thêm vào giỏ
- `updateCartItem(productId, quantity)`: Cập nhật số lượng
- `removeFromCart(productId)`: Xóa khỏi giỏ
- `applyDiscount(code)`: Áp dụng mã giảm giá

### 4. OrderService
- `createOrder(data)`: Tạo đơn hàng
- `getMyOrders()`: Lấy đơn hàng của user
- `getOrderById(id)`: Chi tiết đơn
- `cancelOrder(id)`: Hủy đơn

---

## Luồng Hoạt Động Chính

### 1. Đăng nhập/Đăng ký:
1. User nhập email, password
2. AuthProvider.login() → AuthService.login()
3. Nhận token, lưu vào SharedPreferences
4. Navigate đến HomePage

### 2. Xem sản phẩm:
1. HomePage load: ProductProvider.loadHomeData()
2. Hiển thị Featured, New, Best Sellers
3. Click vào sản phẩm → ProductDetailPage

### 3. Thêm vào giỏ hàng:
1. Click "Thêm vào giỏ" → CartProvider.addToCart()
2. CartService.addToCart() → POST /api/cart/add
3. Hiển thị badge số lượng trên cart icon

### 4. Thanh toán:
1. CartPage → Click "Thanh toán"
2. CheckoutPaymentPage: chọn địa chỉ, phương thức thanh toán
3. OrderProvider.createOrder() → POST /api/orders
4. Navigate đến OrderSuccessPage

---

## Lưu Ý Quan Trọng

1. **Pagination**: Hầu hết API có hỗ trợ phân trang với query params `page` và `limit`
2. **Error Handling**: Tất cả providers đều có `error` state
3. **Loading State**: Tất cả providers đều có `isLoading`
4. **Provider Pattern**: Sử dụng Provider để quản lý state
5. **Authentication**: Sử dụng JWT Token, lưu trong SharedPreferences

---

## UI/UX Features

1. **Lazy Loading Images**: Sử dụng LazyImage component
2. **Pull to Refresh**: Hầu hết pages có hỗ trợ
3. **Infinite Scroll**: Products page có pagination
4. **Search**: Tìm kiếm realtime
5. **Filter & Sort**: Lọc theo category, brand, price range
6. **3D/AR Viewer**: Xem mô hình 3D và AR của sản phẩm
7. **Wishlist**: Lưu sản phẩm yêu thích
8. **Review System**: Đánh giá sản phẩm
9. **Promotion Codes**: Áp dụng mã giảm giá

---

Tài liệu này cung cấp đầy đủ thông tin về ứng dụng Furniture Shop để hỗ trợ người dùng hiệu quả.
''';
