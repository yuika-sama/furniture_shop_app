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

  /// [GET] /api/brands/popular - Lấy thương hiệu phổ biến
  Future<Map<String, dynamic>> getPopularBrands({int limit = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/brands/popular',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final brandsJson = response.data['brands'] as List;
        final brands = brandsJson.map((json) => BrandModel.fromJson(json)).toList();

        return {
          'success': true,
          'brands': brands,
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

  /// [GET] /api/brands/:slug - Lấy thương hiệu theo slug
  Future<Map<String, dynamic>> getBrandBySlug(String slug) async {
    try {
      final response = await _apiClient.dio.get('/api/brands/$slug');

      if (response.data['success'] == true) {
        final brand = BrandModel.fromJson(response.data['brand']);

        return {
          'success': true,
          'brand': brand,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Không tìm thấy thương hiệu',
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