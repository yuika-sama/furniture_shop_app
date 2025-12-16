import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelCacheService {
  static const String _cacheKeyPrefix = 'model_cache_';
  final Dio _dio = Dio();

  /// Download model file từ URL và lưu vào local storage
  /// Returns: local file path nếu thành công, null nếu lỗi
  Future<String?> downloadAndCacheModel({
    required String productId,
    required String modelUrl,
    Function(double progress)? onProgress,
  }) async {
    try {
      // 1. Check nếu đã cache
      final cachedPath = await getCachedModelPath(productId);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return cachedPath;
        } else {
          // File đã bị xóa, clear cache
          await _clearCacheForProduct(productId);
        }
      }

      // 2. Lấy thư mục lưu file
      final directory = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${directory.path}/3d_models');
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      // 3. Tạo tên file unique dựa trên productId
      final fileName = '${productId}_model.glb';
      final filePath = '${modelsDir.path}/$fileName';


      // 4. Download file với progress tracking
      await _dio.download(
        modelUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      // 5. Verify file đã download
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File download failed - file not found');
      }

      final fileSize = await file.length();
      // 6. Lưu mapping vào SharedPreferences
      await _saveCacheMapping(productId, filePath);


      return filePath;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// Lấy đường dẫn file model đã cache
  Future<String?> getCachedModelPath(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_cacheKeyPrefix$productId');
    } catch (e) {
      debugPrint('Error getting cached path: $e');
      return null;
    }
  }

  /// Lưu mapping giữa productId và file path
  Future<void> _saveCacheMapping(String productId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cacheKeyPrefix$productId', filePath);
  }

  /// Xóa cache cho một sản phẩm cụ thể
  Future<void> _clearCacheForProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cacheKeyPrefix$productId');
  }

  /// Xóa cache cho một sản phẩm và file tương ứng
  Future<bool> deleteCachedModel(String productId) async {
    try {
      final cachedPath = await getCachedModelPath(productId);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _clearCacheForProduct(productId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting cached model: $e');
      return false;
    }
  }
}
