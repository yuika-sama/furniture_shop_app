import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_storage_service.dart';

class ApiClient {
  late Dio dio;
  String baseUrl = "https://furniture-shop-backend.vercel.app";

  ApiClient() {
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
        
        // Log request (chỉ trong development)
        print('📤 [${options.method}] ${options.uri}');
        if (options.queryParameters.isNotEmpty) {
          print('   Query: ${options.queryParameters}');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response (chỉ trong development)
        print('✅ [${response.statusCode}] ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Log error
        print('❌ [${e.response?.statusCode}] ${e.requestOptions.uri}');
        print('   Error: ${e.message}');
        
        if (e.response?.statusCode == 401) {
          await TokenStorageService.clearAll();
          // TODO: Navigate to login
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