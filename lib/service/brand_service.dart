import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/brand_model.dart';

class BrandService {
  final ApiClient _apiClient;

  BrandService(this._apiClient);

  /// [GET] /api/brands - Lấy tất cả thương hiệu
  Future<Map<String, dynamic>> getAllBrands({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.dio.get(
        '/api/brands',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final brandsJson = response.data['brands'] as List;
        final brands = brandsJson.map((json) => BrandModel.fromJson(json)).toList();

        return {
          'success': true,
          'brands': brands,
          'pagination': response.data['pagination'], // có thể null
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Lỗi không xác định',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Lỗi kết nối',
        'error': e.message,
      };
    }
  }
}