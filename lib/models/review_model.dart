class ReviewModel {
  final String id;
  final String product;
  final String user;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields (optional)
  final ReviewUser? userDetails;
  final ReviewProduct? productDetails;

  ReviewModel({
    required this.id,
    required this.product,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.userDetails,
    this.productDetails,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      product: json['product'] is String ? json['product'] : json['product']?['_id'] ?? '',
      user: json['user'] is String ? json['user'] : json['user']?['_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      userDetails: json['user'] is Map<String, dynamic> 
          ? ReviewUser.fromJson(json['user']) 
          : null,
      productDetails: json['product'] is Map<String, dynamic> 
          ? ReviewProduct.fromJson(json['product']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': product,
      'user': user,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (userDetails != null) 'userDetails': userDetails!.toJson(),
      if (productDetails != null) 'productDetails': productDetails!.toJson(),
    };
  }

  // Getters
  String get userName => userDetails?.fullName ?? 'Anonymous';
  String get userAvatar => userDetails?.avatar ?? '';
  String get productName => productDetails?.name ?? '';
  String get productSlug => productDetails?.slug ?? '';
  String get productImage => productDetails?.images.isNotEmpty == true 
      ? productDetails!.images.first 
      : '';

  // Time ago text
  String get timeAgoText {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years > 1 ? "năm" : "năm"} trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months > 1 ? "tháng" : "tháng"} trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays > 1 ? "ngày" : "ngày"} trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours > 1 ? "giờ" : "giờ"} trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes > 1 ? "phút" : "phút"} trước';
    } else {
      return 'Vừa xong';
    }
  }

  // Is edited
  bool get isEdited => updatedAt.difference(createdAt).inSeconds > 60;
}

// User info in review
class ReviewUser {
  final String id;
  final String fullName;
  final String? avatar;

  ReviewUser({
    required this.id,
    required this.fullName,
    this.avatar,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      if (avatar != null) 'avatar': avatar,
    };
  }
}

// Product info in review
class ReviewProduct {
  final String id;
  final String name;
  final String slug;
  final List<String> images;

  ReviewProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.images = const [],
  });

  factory ReviewProduct.fromJson(Map<String, dynamic> json) {
    return ReviewProduct(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'images': images,
    };
  }
}

// Rating statistics
class RatingStats {
  final int rating;
  final int count;

  RatingStats({
    required this.rating,
    required this.count,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      rating: json['_id'] ?? 0,
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': rating,
      'count': count,
    };
  }
}

// Reviews response with pagination
class ReviewsResponse {
  final List<ReviewModel> reviews;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<RatingStats>? ratingStats;

  ReviewsResponse({
    required this.reviews,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    this.ratingStats,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      reviews: json['reviews'] != null
          ? List<ReviewModel>.from(
              json['reviews'].map((x) => ReviewModel.fromJson(x)))
          : [],
      page: json['pagination']?['page'] ?? 1,
      limit: json['pagination']?['limit'] ?? 10,
      total: json['pagination']?['total'] ?? 0,
      totalPages: json['pagination']?['totalPages'] ?? 0,
      ratingStats: json['ratingStats'] != null
          ? List<RatingStats>.from(
              json['ratingStats'].map((x) => RatingStats.fromJson(x)))
          : null,
    );
  }

  // Helper: Get count by rating
  int getCountByRating(int rating) {
    if (ratingStats == null) return 0;
    final stat = ratingStats!.firstWhere(
      (s) => s.rating == rating,
      orElse: () => RatingStats(rating: rating, count: 0),
    );
    return stat.count;
  }

  // Helper: Get percentage by rating
  double getPercentageByRating(int rating) {
    if (total == 0) return 0.0;
    final count = getCountByRating(rating);
    return (count / total) * 100;
  }
}
