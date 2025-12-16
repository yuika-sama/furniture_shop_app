# Homi - Furniture Shop App

Ứng dụng mua sắm nội thất trực tuyến - BTL cuối kỳ môn Lập Trình Ứng Dụng Di Động

## Giới thiệu

Furniture Shop App là ứng dụng di động được xây dựng bằng Flutter, cho phép người dùng duyệt, tìm kiếm và mua sắm các sản phẩm nội thất một cách thuận tiện. Ứng dụng tích hợp AI chatbot hỗ trợ tư vấn sản phẩm thông minh.

## Tính năng chính

### Xác thực & Tài khoản

- Đăng ký/Đăng nhập tài khoản
- Quên mật khẩu (gửi email reset)
- Đổi mật khẩu
- Quản lý thông tin cá nhân
- Quản lý địa chỉ giao hàng

### Mua sắm

- Duyệt sản phẩm theo danh mục
- Tìm kiếm sản phẩm
- Xem chi tiết sản phẩm với hình ảnh, mô tả, đánh giá
- Thêm sản phẩm vào giỏ hàng
- Quản lý giỏ hàng (tăng/giảm số lượng, xóa sản phẩm)
- Áp dụng mã giảm giá
- Đặt hàng với phương thức COD

### Yêu thích

- Thêm/xóa sản phẩm khỏi danh sách yêu thích
- Xem danh sách sản phẩm yêu thích
- Thêm nhanh từ wishlist vào giỏ hàng

### Đơn hàng

- Xem lịch sử đơn hàng
- Theo dõi trạng thái đơn hàng (Chờ xử lý, Đang xử lý, Đang giao, Hoàn thành)
- Xem chi tiết đơn hàng
- Hủy đơn hàng (nếu chưa xử lý)

### Khuyến mãi

- Xem danh sách khuyến mãi
- Copy mã giảm giá vào clipboard
- Áp dụng mã giảm giá khi thanh toán

### AI Chatbot

- Tư vấn sản phẩm thông minh với Google Gemini AI
- Trả lời câu hỏi về sản phẩm
- Gợi ý sản phẩm phù hợp

### Đánh giá & Nhận xét

- Xem đánh giá sản phẩm từ người dùng khác
- Viết đánh giá cho sản phẩm đã mua(On update)
- Xếp hạng sản phẩm (1-5 sao)(On update)

## Cài đặt

### Yêu cầu

- Flutter SDK 3.5.4 trở lên
- Dart 3.5.4 trở lên
- Android Studio / Xcode (cho build Android/iOS)
- Git

### Bước 1: Clone repository

```bash
git clone <repository-url>
cd furniture_shop_app
```

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Cấu hình API keys

```bash
# Copy file template
cp lib/constants/app_config.example.dart lib/constants/app_config.dart
```

Mở file `lib/constants/app_config.dart` và cập nhật:

- `baseUrl`: URL backend API (mặc định: https://furniture-shop-backend.vercel.app)
- `geminiApiKey`: API key của Google Gemini AI (lấy từ https://makersuite.google.com/app/apikey)

**Chi tiết về cấu hình bảo mật, xem file app_config_sample**

### Bước 4: Chạy ứng dụng

```bash
# Development
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Cấu trúc dự án

```
lib/
├── main.dart                    # Entry point
├── components/                  # Reusable components
│   ├── main_scaffold.dart      # Bottom navigation wrapper
│   ├── product_card.dart       # Product display card
│   └── ...
├── constants/                   # Constants & configs
│   ├── app_config.dart         # ⚠️ API keys (not in git)
│   ├── app_config.example.dart # Template
│   └── app_theme.dart          # Theme & colors
├── models/                      # Data models
│   ├── product_model.dart
│   ├── order_model.dart
│   ├── user_model.dart
│   └── ...
├── pages/                       # Screen pages
│   ├── home_page.dart
│   ├── product_detail_page.dart
│   ├── cart_page.dart
│   ├── checkout_page.dart
│   ├── orders_page.dart
│   ├── account_page.dart
│   └── ...
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   ├── order_provider.dart
│   └── ...
├── service/                     # API services
│   ├── api_client.dart         # HTTP client
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── order_service.dart
│   ├── chat_service.dart       # Gemini AI
│   └── ...
└── utils/                       # Utilities
    └── ...
```

## Công nghệ sử dụng

### Framework & Language

- **Flutter 3.5.4** - UI framework
- **Dart 3.5.4** - Programming language

### State Management

- **Provider 6.1.2** - State management solution

### Networking

- **Dio 5.7.0** - HTTP client
- **http** - Additional HTTP support

### UI Components

- **Material 3** - Design system
- **cached_network_image** - Image caching
- **flutter_native_splash** - Splash screen
- **carousel_slider** - Image carousel

### Storage & Security

- **flutter_secure_storage** - Secure token storage
- **shared_preferences** - Local preferences

### AI & Chat

- **google_generative_ai 0.4.6** - Google Gemini AI integration

### Utilities

- **intl 0.19.0** - Internationalization & date formatting
- **url_launcher** - Launch URLs/phone/email
- **image_picker** - Pick images from gallery/camera
- **permission_handler** - Handle permissions

### Development Tools

- **flutter_lints** - Code analysis

## Bảo mật

- API keys và URLs nhạy cảm **KHÔNG** được commit vào git
- File `lib/constants/app_config.dart` nằm trong `.gitignore`
- Sử dụng `flutter_secure_storage` để lưu access token
- Production build sử dụng `--dart-define` để inject environment variables
- Backend API

Backend repository: [furniture-shop-backend](https://github.com/PhamHaThang/furniture-shop-backend)

API Documentation: Xem trong backend repository

Base URL (Production): https://furniture-shop-backend.vercel.app

## Nhóm phát triển

BTL cuối kỳ môn Lập Trình Ứng Dụng Di Động

- Thành viên 1: Nguyễn Đức Anh - B22DCPT009
- Thành viên 2: Phạm Hà Thắng - B22DCPT261
- Thành viên 3: Văn Thiên Phúc - B22DCPT209

## License

Sản phẩm chỉ phục vụ cho mục đích học tập, giáo dục

## Liên hệ

Nếu có câu hỏi hoặc góp ý, vui lòng liên hệ qua:

- Email: nguyenanhduc2938@gmail.com
- Facebook: fb.com/yonni1412

---

**Lưu ý:** Đây là dự án học tập, không sử dụng cho mục đích thương mại.
