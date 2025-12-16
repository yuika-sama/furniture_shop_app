import 'package:dio/dio.dart';
import 'token_storage_service.dart';

class ApiClient {
  late Dio dio;
  String baseUrl = "https://furniture-shop-backend.vercel.app";
  Function()? onUnauthorized;

  ApiClient({this.onUnauthorized}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    // Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await TokenStorageService.getAccessToken();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        
        // Handle 401 (Unauthorized) or 403 (Forbidden) - Token expired or invalid
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          
          // Clear all stored tokens
          await TokenStorageService.clearAll();
          
          // Notify app to logout (if callback is set)
          if (onUnauthorized != null) {
            onUnauthorized!();
          }
        }
        
        return handler.next(e);
      },
    ));
  }

  /// Get full image URL from relative path
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/400x400?text=No+Image';
    }
    if (path.startsWith('http')) return path;
    return '$baseUrl/$path';
  }

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}