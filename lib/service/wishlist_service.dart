import '../constants/api_constants.dart';
import '../models/wishlist_model.dart';
import 'api_client.dart';

class WishlistService {
  final ApiClient _apiClient = ApiClient();

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

  /// Add multiple products to wishlist
  Future<WishlistResponse> addMultipleToWishlist(List<String> productIds) async {
    try {
      if (productIds.isEmpty) {
        throw Exception('Danh sách sản phẩm trống');
      }

      // Add products one by one
      // Backend doesn't have bulk add endpoint
      WishlistResponse? result;
      
      for (final productId in productIds) {
        try {
          result = await addToWishlist(productId);
        } catch (e) {
          // Continue if product already in wishlist or other error
          continue;
        }
      }

      // Return final result or get fresh wishlist
      return result ?? await getWishlist();
    } catch (e) {
      rethrow;
    }
  }

  /// Remove multiple products from wishlist
  Future<WishlistResponse> removeMultipleFromWishlist(List<String> productIds) async {
    try {
      if (productIds.isEmpty) {
        throw Exception('Danh sách sản phẩm trống');
      }

      // Remove products one by one
      WishlistResponse? result;
      
      for (final productId in productIds) {
        try {
          result = await removeFromWishlist(productId);
        } catch (e) {
          // Continue on error
          continue;
        }
      }

      // Return final result or get fresh wishlist
      return result ?? await getWishlist();
    } catch (e) {
      rethrow;
    }
  }

  /// Get wishlist product IDs only (lightweight)
  Future<List<String>> getWishlistProductIds() async {
    try {
      final wishlist = await getWishlist();
      return wishlist.wishlist.productIds;
    } catch (e) {
      return [];
    }
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    try {
      final wishlist = await getWishlist();
      return wishlist.count;
    } catch (e) {
      return 0;
    }
  }

  /// Sync wishlist (refresh from server)
  Future<WishlistResponse> syncWishlist() async {
    return await getWishlist();
  }
}
