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
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📥 Starting model download...');
      debugPrint('Product ID: $productId');
      debugPrint('Model URL: $modelUrl');
      
      // 1. Check nếu đã cache
      final cachedPath = await getCachedModelPath(productId);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          debugPrint('✅ Model already cached at: $cachedPath');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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

      debugPrint('📁 Saving to: $filePath');

      // 4. Download file với progress tracking
      await _dio.download(
        modelUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            debugPrint('📊 Download progress: ${(progress * 100).toStringAsFixed(1)}%');
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
      debugPrint('✅ Download complete! File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // 6. Lưu mapping vào SharedPreferences
      await _saveCacheMapping(productId, filePath);

      debugPrint('💾 Cached mapping saved');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return filePath;
    } catch (e, stackTrace) {
      debugPrint('❌ Error downloading model: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return null;
    }
  }

  /// Lấy đường dẫn file model đã cache (nếu có)
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
        debugPrint('🗑️ Deleted cached model for product: $productId');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting cached model: $e');
      return false;
    }
  }

  /// Lấy tổng dung lượng cache đã sử dụng
  Future<int> getCacheSizeInBytes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${directory.path}/3d_models');
      
      if (!await modelsDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (var entity in modelsDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Xóa toàn bộ cache
  Future<void> clearAllCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${directory.path}/3d_models');
      
      if (await modelsDir.exists()) {
        await modelsDir.delete(recursive: true);
      }

      // Xóa tất cả cache keys
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (var key in keys) {
        if (key.startsWith(_cacheKeyPrefix)) {
          await prefs.remove(key);
        }
      }

      debugPrint('🗑️ Cleared all model cache');
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  /// Get danh sách tất cả các models đã cache
  Future<List<String>> getCachedProductIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      return keys
          .where((key) => key.startsWith(_cacheKeyPrefix))
          .map((key) => key.replaceFirst(_cacheKeyPrefix, ''))
          .toList();
    } catch (e) {
      debugPrint('Error getting cached product IDs: $e');
      return [];
    }
  }
}
