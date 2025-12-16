import '../constants/api_constants.dart';
import '../models/review_model.dart';
import 'api_client.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService(this._apiClient);

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
}
