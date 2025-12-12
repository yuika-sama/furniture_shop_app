import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class UploadService {
  final ApiClient _apiClient;

  UploadService(this._apiClient);

  // ========== UPLOAD ROUTES (Admin only) ==========

  /// [POST] /api/upload/image - Upload single image
  /// 
  /// Requirements:
  /// - Admin only
  /// - Supported formats: jpg, jpeg, png, gif, webp
  /// - Max size: 10MB
  /// 
  /// Returns: UploadResult with url, publicId, format, dimensions, size
  Future<UploadResult> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      // Validate file extension
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
        throw Exception('Định dạng file không được hỗ trợ. Chỉ chấp nhận: jpg, jpeg, png, gif, webp');
      }

      // Create form data
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', fileExtension),
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.uploadImage,
        data: formData,
      );

      return UploadResult.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// [POST] /api/upload/images - Upload multiple images (max 10)
  /// 
  /// Requirements:
  /// - Admin only
  /// - Max 10 images per request
  /// - Supported formats: jpg, jpeg, png, gif, webp
  /// - Max size per image: 10MB
  /// 
  /// Returns: List<UploadResult>
  Future<List<UploadResult>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('Vui lòng chọn ít nhất 1 ảnh');
      }

      if (imageFiles.length > 10) {
        throw Exception('Chỉ được upload tối đa 10 ảnh cùng lúc');
      }

      // Validate all files
      for (var file in imageFiles) {
        String fileName = file.path.split('/').last;
        String fileExtension = fileName.split('.').last.toLowerCase();
        
        if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
          throw Exception('File $fileName có định dạng không được hỗ trợ');
        }
      }

      // Create form data with multiple files
      FormData formData = FormData.fromMap({
        'images': await Future.wait(
          imageFiles.map((file) async {
            String fileName = file.path.split('/').last;
            String fileExtension = fileName.split('.').last.toLowerCase();
            
            return await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType('image', fileExtension),
            );
          }),
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.uploadImages,
        data: formData,
      );

      final List<dynamic> data = response.data['data'];
      return data.map((item) => UploadResult.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// [POST] /api/upload/3d-model - Upload 3D model file
  /// 
  /// Requirements:
  /// - Admin only
  /// - Supported formats: glb, gltf, obj, fbx, usdz
  /// - Max size: 50MB
  /// 
  /// Returns: Upload3DResult with url, publicId, format, size
  Future<Upload3DResult> upload3DModel(File modelFile) async {
    try {
      String fileName = modelFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      // Validate file extension
      if (!['glb', 'gltf', 'obj', 'fbx', 'usdz'].contains(fileExtension)) {
        throw Exception('Định dạng file không được hỗ trợ. Chỉ chấp nhận: glb, gltf, obj, fbx, usdz');
      }

      // Create form data
      FormData formData = FormData.fromMap({
        'model': await MultipartFile.fromFile(
          modelFile.path,
          filename: fileName,
          contentType: MediaType('application', 'octet-stream'),
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.upload3DModel,
        data: formData,
      );

      return Upload3DResult.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/upload/delete - Delete single file from Cloudinary
  /// 
  /// Requirements:
  /// - Admin only
  /// 
  /// Params:
  /// - publicId: Cloudinary public ID
  /// - resourceType: 'image' (default), 'raw', 'video'
  Future<void> deleteFile({
    required String publicId,
    String resourceType = 'image',
  }) async {
    try {
      if (publicId.trim().isEmpty) {
        throw Exception('Vui lòng cung cấp publicId');
      }

      await _apiClient.delete(
        ApiConstants.uploadDelete,
        data: {
          'publicId': publicId,
          'resourceType': resourceType,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// [DELETE] /api/upload/delete-multiple - Delete multiple files
  /// 
  /// Requirements:
  /// - Admin only
  /// 
  /// Params:
  /// - publicIds: List of Cloudinary public IDs
  /// - resourceType: 'image' (default), 'raw', 'video'
  /// 
  /// Returns: DeleteMultipleResult with success count
  Future<DeleteMultipleResult> deleteMultipleFiles({
    required List<String> publicIds,
    String resourceType = 'image',
  }) async {
    try {
      if (publicIds.isEmpty) {
        throw Exception('Vui lòng cung cấp danh sách publicIds');
      }

      final response = await _apiClient.delete(
        ApiConstants.uploadDeleteMultiple,
        data: {
          'publicIds': publicIds,
          'resourceType': resourceType,
        },
      );

      return DeleteMultipleResult.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========

  /// Upload product images
  /// Helper để upload nhiều ảnh cho sản phẩm
  Future<List<String>> uploadProductImages(List<File> images) async {
    final results = await uploadMultipleImages(images);
    return results.map((r) => r.url).toList();
  }

  /// Delete product images
  /// Helper để xóa nhiều ảnh của sản phẩm
  Future<void> deleteProductImages(List<String> imageUrls) async {
    // Extract publicIds from URLs
    final publicIds = imageUrls
        .map((url) => _extractPublicIdFromUrl(url))
        .where((id) => id != null)
        .cast<String>()
        .toList();

    if (publicIds.isNotEmpty) {
      await deleteMultipleFiles(publicIds: publicIds);
    }
  }

  /// Extract publicId from Cloudinary URL
  String? _extractPublicIdFromUrl(String url) {
    try {
      // Cloudinary URL format: https://res.cloudinary.com/{cloud_name}/{resource_type}/upload/{transformations}/{version}/{public_id}.{format}
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find 'upload' segment
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 1) {
        return null;
      }

      // Get segments after 'upload' (skip version if exists)
      final afterUpload = pathSegments.sublist(uploadIndex + 1);
      
      // Skip version segment (starts with 'v' followed by numbers)
      final startIndex = afterUpload.isNotEmpty && 
          afterUpload[0].startsWith('v') && 
          int.tryParse(afterUpload[0].substring(1)) != null
          ? 1
          : 0;

      if (startIndex >= afterUpload.length) return null;

      // Join remaining segments and remove extension
      final publicIdWithExt = afterUpload.sublist(startIndex).join('/');
      final lastDotIndex = publicIdWithExt.lastIndexOf('.');
      
      return lastDotIndex != -1 
          ? publicIdWithExt.substring(0, lastDotIndex)
          : publicIdWithExt;
    } catch (e) {
      return null;
    }
  }

  /// Validate image file before upload
  Future<bool> validateImageFile(File file, {int maxSizeInMB = 10}) async {
    try {
      // Check file exists
      if (!await file.exists()) {
        throw Exception('File không tồn tại');
      }

      // Check file size
      final fileSize = await file.length();
      final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
      
      if (fileSize > maxSizeInBytes) {
        throw Exception('Kích thước file vượt quá ${maxSizeInMB}MB');
      }

      // Check extension
      String fileName = file.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
        throw Exception('Định dạng file không được hỗ trợ');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}

// ========== MODELS ==========

/// Upload result for images
class UploadResult {
  final String url;
  final String publicId;
  final String format;
  final int? width;
  final int? height;
  final int? size;

  UploadResult({
    required this.url,
    required this.publicId,
    required this.format,
    this.width,
    this.height,
    this.size,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      format: json['format'] ?? '',
      width: json['width'],
      height: json['height'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
      'format': format,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (size != null) 'size': size,
    };
  }

  // Helpers
  String get sizeText {
    if (size == null) return 'Unknown';
    final sizeInKB = size! / 1024;
    if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(1)} KB';
    }
    final sizeInMB = sizeInKB / 1024;
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  String get dimensionsText {
    if (width == null || height == null) return 'Unknown';
    return '${width}x${height}';
  }
}

/// Upload result for 3D models
class Upload3DResult {
  final String url;
  final String publicId;
  final String format;
  final String resourceType;
  final int? size;

  Upload3DResult({
    required this.url,
    required this.publicId,
    required this.format,
    required this.resourceType,
    this.size,
  });

  factory Upload3DResult.fromJson(Map<String, dynamic> json) {
    return Upload3DResult(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      format: json['format'] ?? '',
      resourceType: json['resourceType'] ?? 'raw',
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
      'format': format,
      'resourceType': resourceType,
      if (size != null) 'size': size,
    };
  }

  String get sizeText {
    if (size == null) return 'Unknown';
    final sizeInMB = size! / (1024 * 1024);
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }
}

/// Delete multiple files result
class DeleteMultipleResult {
  final int total;
  final int success;
  final int failed;
  final List<dynamic>? details;

  DeleteMultipleResult({
    required this.total,
    required this.success,
    required this.failed,
    this.details,
  });

  factory DeleteMultipleResult.fromJson(Map<String, dynamic> json) {
    return DeleteMultipleResult(
      total: json['total'] ?? 0,
      success: json['success'] ?? 0,
      failed: json['failed'] ?? 0,
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'success': success,
      'failed': failed,
      if (details != null) 'details': details,
    };
  }

  bool get isFullSuccess => success == total;
  bool get hasFailures => failed > 0;
  double get successRate => total > 0 ? (success / total) * 100 : 0;
}
