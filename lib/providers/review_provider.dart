import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../service/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService;

  ReviewProvider(this._reviewService);

  // State
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  // Rating statistics
  List<RatingStats> _ratingStats = [];

  // Current product reviews
  String? _currentProductId;

  // Getters
  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  List<RatingStats> get ratingStats => _ratingStats;
  bool get hasMore => _currentPage < _totalPages;

  // Rating statistics helpers
  int getCountByRating(int rating) {
    final stat = _ratingStats.firstWhere(
      (s) => s.rating == rating,
      orElse: () => RatingStats(rating: rating, count: 0),
    );
    return stat.count;
  }

  double getPercentageByRating(int rating) {
    if (_total == 0) return 0.0;
    final count = getCountByRating(rating);
    return (count / _total) * 100;
  }

  double get averageRating {
    if (_ratingStats.isEmpty || _total == 0) return 0.0;

    int totalRating = 0;
    for (var stat in _ratingStats) {
      totalRating += stat.rating * stat.count;
    }

    return totalRating / _total;
  }

  // Load reviews by product
  Future<void> loadReviewsByProduct(
    String productId, {
    int page = 1,
    int limit = 10,
    int? rating,
    String sortBy = '-createdAt',
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        _isLoading = true;
        _errorMessage = null;
        _currentProductId = productId;
        notifyListeners();
      }

      final response = await _reviewService.getReviewsByProduct(
        productId,
        page: page,
        limit: limit,
        rating: rating,
        sortBy: sortBy,
      );

      if (loadMore) {
        _reviews.addAll(response.reviews);
      } else {
        _reviews = response.reviews;
        _ratingStats = response.ratingStats ?? [];
      }

      _currentPage = response.page;
      _totalPages = response.totalPages;
      _total = response.total;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more reviews
  Future<void> loadMoreReviews({
    int? rating,
    String sortBy = '-createdAt',
  }) async {
    if (!hasMore || _isLoading || _currentProductId == null) return;

    await loadReviewsByProduct(
      _currentProductId!,
      page: _currentPage + 1,
      rating: rating,
      sortBy: sortBy,
      loadMore: true,
    );
  }

  // Create review
  Future<bool> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final review = await _reviewService.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      // Add to top of list
      _reviews.insert(0, review);
      _total++;

      // Update rating stats
      final statIndex = _ratingStats.indexWhere((s) => s.rating == rating);
      if (statIndex != -1) {
        _ratingStats[statIndex] = RatingStats(
          rating: rating,
          count: _ratingStats[statIndex].count + 1,
        );
      } else {
        _ratingStats.add(RatingStats(rating: rating, count: 1));
      }
      _ratingStats.sort((a, b) => b.rating.compareTo(a.rating));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update review
  Future<bool> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedReview = await _reviewService.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );

      // Update in list
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final oldRating = _reviews[index].rating;
        _reviews[index] = updatedReview;

        // Update rating stats if rating changed
        if (rating != null && rating != oldRating) {
          // Decrease old rating count
          final oldStatIndex = _ratingStats.indexWhere((s) => s.rating == oldRating);
          if (oldStatIndex != -1) {
            final newCount = _ratingStats[oldStatIndex].count - 1;
            if (newCount > 0) {
              _ratingStats[oldStatIndex] = RatingStats(
                rating: oldRating,
                count: newCount,
              );
            } else {
              _ratingStats.removeAt(oldStatIndex);
            }
          }

          // Increase new rating count
          final newStatIndex = _ratingStats.indexWhere((s) => s.rating == rating);
          if (newStatIndex != -1) {
            _ratingStats[newStatIndex] = RatingStats(
              rating: rating,
              count: _ratingStats[newStatIndex].count + 1,
            );
          } else {
            _ratingStats.add(RatingStats(rating: rating, count: 1));
          }
          _ratingStats.sort((a, b) => b.rating.compareTo(a.rating));
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete review
  Future<bool> deleteReview(String reviewId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _reviewService.deleteReview(reviewId);

      // Remove from list
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final deletedReview = _reviews[index];
        _reviews.removeAt(index);
        _total--;

        // Update rating stats
        final statIndex = _ratingStats.indexWhere((s) => s.rating == deletedReview.rating);
        if (statIndex != -1) {
          final newCount = _ratingStats[statIndex].count - 1;
          if (newCount > 0) {
            _ratingStats[statIndex] = RatingStats(
              rating: deletedReview.rating,
              count: newCount,
            );
          } else {
            _ratingStats.removeAt(statIndex);
          }
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin: Load all reviews
  Future<void> loadAllReviewsAdmin({
    int page = 1,
    int limit = 20,
    int? rating,
    String? productId,
    String? userId,
    String? search,
    String sortBy = '-createdAt',
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      }

      final response = await _reviewService.getAllReviewsAdmin(
        page: page,
        limit: limit,
        rating: rating,
        productId: productId,
        userId: userId,
        search: search,
        sortBy: sortBy,
      );

      if (loadMore) {
        _reviews.addAll(response.reviews);
      } else {
        _reviews = response.reviews;
      }

      _currentPage = response.page;
      _totalPages = response.totalPages;
      _total = response.total;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Admin: Delete review
  Future<bool> adminDeleteReview(String reviewId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _reviewService.adminDeleteReview(reviewId);

      // Remove from list
      _reviews.removeWhere((r) => r.id == reviewId);
      _total--;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear state
  void clear() {
    _reviews = [];
    _ratingStats = [];
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _currentProductId = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh reviews
  Future<void> refresh() async {
    if (_currentProductId != null) {
      await loadReviewsByProduct(_currentProductId!);
    }
  }
}
