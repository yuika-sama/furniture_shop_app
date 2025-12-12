/// Generic API Response wrapper
/// Để wrap các response từ backend với cấu trúc thống nhất
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? pagination;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.pagination,
    this.error,
  });

  /// Success response
  factory ApiResponse.success({
    required T data,
    String? message,
    Map<String, dynamic>? pagination,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      pagination: pagination,
    );
  }

  /// Error response
  factory ApiResponse.error({
    required String message,
    String? error,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      error: error,
    );
  }
}

/// Pagination info từ backend
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
