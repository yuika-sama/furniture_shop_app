import '../constants/api_constants.dart';
import '../models/review_model.dart';
import 'api_client.dart';

class ReviewService {
  final ApiClient _apiClient = ApiClient();

  // ========== PUBLIC ROUTES ==========

  /// [GET] /api/reviews/product/:productId - Lấy đánh giá theo sản phẩm
  /// 
  /// Params:
  /// - productId: ID của sản phẩm
  /// - page: Trang hiện tại (default: 1)
  /// - limit: Số review mỗi trang (default: 10)
  /// - rating: Filter theo rating (1-5)
  /// - sortBy: Sắp xếp (-createdAt, createdAt, -rating, rating)
  /// 
  /// Returns: ReviewsResponse với reviews, pagination, ratingStats
  Future<ReviewsResponse> getReviewsByProduct(
    String productId, {
    int page = 1,
    int limit = 10,
    int? rating,
    String sortBy = '-createdAt',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        if (rating != null) 'rating': rating.toString(),
      };

      final response = await _apiClient.get(
        '${ApiConstants.reviews}/product/$productId',
        queryParameters: queryParams,
      );

      return ReviewsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ========== USER ROUTES ==========

  /// [POST] /api/reviews - Tạo đánh giá cho sản phẩm
  /// 
  /// Requirements:
  /// - User phải đã mua sản phẩm (order status = delivered)
  /// - Mỗi user chỉ review 1 lần cho 1 sản phẩm
  /// - Rating: 1-5 sao
  /// 
  /// Body:
  /// - productId: ID sản phẩm
  /// - rating: 1-5
  /// - comment: Nội dung đánh giá
  Future<ReviewModel> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Đánh giá phải từ 1 đến 5 sao');
      }

      if (comment.trim().isEmpty) {
        throw Exception('Vui lòng nhập nội dung đánh giá');
      }

      final response = await _apiClient.post(
        ApiConstants.reviews,
        data: {
          'productId': productId,
          'rating': rating,
          'comment': comment,
        },
      );

      return ReviewModel.fromJson(response.data['review']);
    } catch (e) {
      rethrow;
    }
  }

  /// [PUT] /api/reviews/:id - Cập nhật đánh giá
  /// 
  /// Requirements:
  /// - Chỉ user sở hữu mới được update
  /// 
  /// Body:
  /// - rating: 1-5 (optional)
  /// - comment: Nội dung mới (optional)
  Future<ReviewModel> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      if (rating != null && (rating < 1 || rating > 5)) {
        throw Exception('Đánh giá phải từ 1 đến 5 sao');
      }

      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (comment != null) data['comment'] = comment;

      if (data.isEmpty) {
        throw Exception('Vui lòng cung cấp thông tin cần cập nhật');
      }

      final response = await _apiClient.put(
        '${ApiConstants.reviews}/$reviewId',
        data: data,
      );

      return ReviewModel.fromJson(response.data['review']);
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/reviews/:id - Xóa đánh giá
  /// 
  /// Requirements:
  /// - Chỉ user sở hữu mới được xóa
  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiClient.delete('${ApiConstants.reviews}/$reviewId');
    } catch (e) {
      rethrow;
    }
  }

  // ========== ADMIN ROUTES ==========

  /// [GET] /api/admin/reviews - Lấy tất cả đánh giá (Admin)
  /// 
  /// Params:
  /// - page: Trang hiện tại (default: 1)
  /// - limit: Số review mỗi trang (default: 20)
  /// - rating: Filter theo rating (1-5)
  /// - productId: Filter theo sản phẩm
  /// - userId: Filter theo user
  /// - search: Tìm kiếm trong comment
  /// - sortBy: Sắp xếp (default: -createdAt)
  Future<ReviewsResponse> getAllReviewsAdmin({
    int page = 1,
    int limit = 20,
    int? rating,
    String? productId,
    String? userId,
    String? search,
    String sortBy = '-createdAt',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        if (rating != null) 'rating': rating.toString(),
        if (productId != null) 'productId': productId,
        if (userId != null) 'userId': userId,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        '${ApiConstants.adminReviews}',
        queryParameters: queryParams,
      );

      return ReviewsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/admin/reviews/:id - Xóa đánh giá (Admin)
  Future<void> adminDeleteReview(String reviewId) async {
    try {
      await _apiClient.delete('${ApiConstants.adminReviews}/$reviewId');
    } catch (e) {
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========

  /// Check if user can review product
  /// (Product chỉ review được khi đã mua và delivered)
  Future<bool> canReviewProduct(String productId) async {
    try {
      // This check is done on backend when creating review
      // Frontend có thể gọi getReviewsByProduct và check xem user đã review chưa
      final reviews = await getReviewsByProduct(productId, limit: 1);
      
      // Nếu cần check chính xác hơn, cần endpoint riêng từ backend
      // hoặc check trong orders của user
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's review for a product
  Future<ReviewModel?> getUserReviewForProduct(String productId) async {
    try {
      // Backend không có endpoint này, phải get all reviews và filter
      // Hoặc có thể add vào backend: GET /api/reviews/my-review/:productId
      final reviews = await getReviewsByProduct(productId);
      
      // Cần userId để filter, tốt nhất backend nên có endpoint riêng
      // Tạm thời return null
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate average rating from rating stats
  double calculateAverageRating(List<RatingStats> stats) {
    if (stats.isEmpty) return 0.0;

    int totalRating = 0;
    int totalCount = 0;

    for (var stat in stats) {
      totalRating += stat.rating * stat.count;
      totalCount += stat.count;
    }

    if (totalCount == 0) return 0.0;
    return totalRating / totalCount;
  }
}
