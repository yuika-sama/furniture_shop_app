import '../constants/api_constants.dart';
import '../models/wishlist_model.dart';
import 'api_client.dart';

class WishlistService {
  final ApiClient _apiClient;

  WishlistService(this._apiClient);

  // ========== USER WISHLIST ROUTES ==========

  /// [GET] /api/wishlist - Lấy danh sách yêu thích
  /// 
  /// Requirements: Auth required
  /// 
  /// Backend behavior:
  /// - Nếu chưa có wishlist, tự động tạo mới
  /// - Auto populate products với select fields:
  ///   name, slug, images, price, salePrice, stock, averageRating, totalReviews
  /// 
  /// Returns: WishlistResponse với wishlist và count
  Future<WishlistResponse> getWishlist() async {
    try {
      final response = await _apiClient.get(ApiConstants.wishlist);
      return WishlistResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// [POST] /api/wishlist/:productId - Thêm sản phẩm vào wishlist
  /// 
  /// Requirements: Auth required
  /// 
  /// Validations:
  /// - Product phải tồn tại
  /// - Product chưa có trong wishlist
  /// 
  /// Returns: WishlistResponse với updated wishlist
  Future<WishlistResponse> addToWishlist(String productId) async {
    try {
      if (productId.trim().isEmpty) {
        throw Exception('Product ID không hợp lệ');
      }

      final response = await _apiClient.post(
        '${ApiConstants.wishlist}/$productId',
      );

      return WishlistResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/wishlist/:productId - Xóa sản phẩm khỏi wishlist
  /// 
  /// Requirements: Auth required
  /// 
  /// Validations:
  /// - Wishlist phải tồn tại
  /// - Product phải có trong wishlist
  /// 
  /// Returns: WishlistResponse với updated wishlist
  Future<WishlistResponse> removeFromWishlist(String productId) async {
    try {
      if (productId.trim().isEmpty) {
        throw Exception('Product ID không hợp lệ');
      }

      final response = await _apiClient.delete(
        '${ApiConstants.wishlist}/$productId',
      );

      return WishlistResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/wishlist - Xóa toàn bộ wishlist
  /// 
  /// Requirements: Auth required
  /// 
  /// Returns: WishlistResponse với empty wishlist
  Future<WishlistResponse> clearWishlist() async {
    try {
      final response = await _apiClient.delete(ApiConstants.wishlist);
      return WishlistResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========

  /// Toggle product in wishlist
  /// Add if not exists, remove if exists
  Future<WishlistResponse> toggleProduct(String productId) async {
    try {
      final wishlist = await getWishlist();
      
      if (wishlist.wishlist.containsProduct(productId)) {
        // Remove from wishlist
        return await removeFromWishlist(productId);
      } else {
        // Add to wishlist
        return await addToWishlist(productId);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      final wishlist = await getWishlist();
      return wishlist.wishlist.containsProduct(productId);
    } catch (e) {
      // If error (e.g., not logged in), return false
      return false;
    }
  }
}
