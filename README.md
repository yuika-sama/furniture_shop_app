# 🛋️ Furniture Shop App

Ứng dụng bán hàng nội thất được xây dựng bằng Flutter - BTL cuối kỳ LTApp

## 📋 Mô tả

Furniture Shop App là một ứng dụng thương mại điện tử chuyên về nội thất, cung cấp trải nghiệm mua sắm toàn diện với các tính năng hiện đại như xem sản phẩm 3D/AR, chatbot hỗ trợ AI, và quản lý đơn hàng.

## ✨ Tính năng chính

### 🔐 Xác thực & Quản lý người dùng
- Đăng ký và đăng nhập tài khoản
- Quên mật khẩu và khôi phục
- Quản lý thông tin cá nhân
- Quản lý địa chỉ giao hàng

### 🛍️ Mua sắm
- Duyệt sản phẩm theo danh mục và thương hiệu
- Tìm kiếm sản phẩm
- Xem chi tiết sản phẩm với hình ảnh và mô tả
- Đánh giá và nhận xét sản phẩm
- Xem sản phẩm dưới dạng 3D (Model Viewer)
- Xem sản phẩm trong AR (Augmented Reality)

### 🛒 Giỏ hàng & Thanh toán
- Thêm/xóa/cập nhật sản phẩm trong giỏ hàng
- Áp dụng mã khuyến mãi
- Thanh toán và tạo đơn hàng
- Theo dõi trạng thái đơn hàng

### ❤️ Yêu thích
- Thêm sản phẩm vào danh sách yêu thích
- Quản lý danh sách yêu thích

### 🤖 Chatbot AI
- Hỗ trợ tư vấn sản phẩm thông qua Google Generative AI
- Trả lời câu hỏi về nội thất

### 🎁 Khuyến mãi
- Xem danh sách chương trình khuyến mãi
- Áp dụng mã giảm giá

## 🏗️ Kiến trúc ứng dụng

### Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── components/              # Các widget tái sử dụng
├── constants/               # Hằng số và theme
├── models/                  # Data models
│   ├── brand_model.dart
│   ├── cart_model.dart
│   ├── category_model.dart
│   ├── order_model.dart
│   ├── product_model.dart
│   ├── promotion_model.dart
│   ├── review_model.dart
│   ├── user_model.dart
│   └── wishlist_model.dart
├── pages/                   # Các màn hình
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── products_page.dart
│   ├── product_detail_page.dart
│   ├── product_3d_viewer_page.dart
│   ├── product_ar_viewer_page.dart
│   ├── cart_page.dart
│   ├── checkout_payment_page.dart
│   ├── orders_page.dart
│   ├── wishlist_page.dart
│   ├── account_page.dart
│   ├── chatbot_page.dart
│   └── ...
├── providers/               # State management (Provider)
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   ├── order_provider.dart
│   └── ...
├── service/                 # API services
│   ├── api_client.dart
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── cart_service.dart
│   ├── chat_service.dart
│   └── ...
└── utils/                   # Tiện ích

```

### State Management
- **Provider**: Quản lý state toàn cục cho authentication, cart, products, orders, etc.

### Network Layer
- **Dio**: HTTP client cho các API calls
- **API Client**: Centralized API configuration với interceptors
- **Secure Storage**: Lưu trữ token authentication an toàn

## 🚀 Cài đặt

### Yêu cầu
- Flutter SDK: ^3.10.3
- Dart SDK: ^3.10.3
- Android Studio / Xcode (cho phát triển mobile)
- VS Code (khuyên dùng)

### Các bước cài đặt

1. **Clone repository**
```bash
git clone <repository-url>
cd furniture_shop_app
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Cấu hình API endpoint**
   - Cập nhật API base URL trong file service configuration

4. **Chạy ứng dụng**
```bash
# Chạy trên simulator/emulator
flutter run

# Chạy trên device cụ thể
flutter run -d <device-id>

# Build release
flutter build apk  # Android
flutter build ios  # iOS
```

## 📦 Dependencies chính

### Core
- `flutter`: SDK
- `provider: ^6.1.2`: State management
- `dio: ^5.9.0`: HTTP client

### UI/UX
- `cupertino_icons: ^1.0.8`: Icons
- `model_viewer_plus: ^1.8.0`: 3D model viewer
- `image_picker: ^1.0.7`: Chọn hình ảnh

### Storage & Security
- `flutter_secure_storage: ^10.0.0`: Secure storage cho tokens
- `shared_preferences: ^2.3.3`: Local preferences
- `path_provider: ^2.1.5`: File system paths

### AI & Integration
- `google_generative_ai: 0.4.6`: Gemini AI chatbot
- `url_launcher: ^6.2.4`: Mở URLs
- `open_file: ^3.3.2`: Mở files

### Utilities
- `permission_handler: ^11.0.0`: Quản lý permissions
- `intl: ^0.20.2`: Internationalization

## 🔧 Cấu hình

### Android
- Minimum SDK: 21
- Target SDK: 34
- Cấu hình permissions trong `AndroidManifest.xml`

### iOS
- Minimum iOS version: 12.0
- Cấu hình permissions trong `Info.plist`

## 🎨 Features nổi bật

### 3D & AR Viewer
Sử dụng `model_viewer_plus` để hiển thị sản phẩm dưới dạng 3D và AR, cho phép khách hàng xem sản phẩm một cách sinh động trước khi mua.

### AI Chatbot
Tích hợp Google Gemini AI để cung cấp chatbot tư vấn thông minh, giúp khách hàng tìm hiểu về sản phẩm nội thất.

### Secure Authentication
Sử dụng `flutter_secure_storage` để lưu trữ token authentication một cách an toàn, kết hợp với API interceptors để tự động refresh token.

## 🧪 Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 📱 Screenshots

_(Thêm screenshots của ứng dụng tại đây)_

## 🤝 Đóng góp

Dự án này là bài tập lớn cuối kỳ môn Lập trình App.

## 📄 License

Copyright © 2026. All rights reserved.

## 👥 Tác giả

_(Thêm thông tin tác giả tại đây)_

## 📞 Liên hệ

_(Thêm thông tin liên hệ tại đây)_

---

**Note**: Đây là dự án học tập, không dùng cho mục đích thương mại.
