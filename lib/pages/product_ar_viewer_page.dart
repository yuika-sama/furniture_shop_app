import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../constants/app_theme.dart';
import '../models/product_model.dart';
import '../service/api_client.dart';
import '../service/model_cache_service.dart';

class ProductNativeARPage extends StatefulWidget {
  final ProductModel product;

  const ProductNativeARPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductNativeARPage> createState() => _ProductNativeARPageState();
}

class _ProductNativeARPageState extends State<ProductNativeARPage> {
  late final ApiClient _apiClient;
  late final ModelCacheService _cacheService;

  bool _isDownloading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _localModelPath;
  String? _remoteModelUrl;
  double _downloadProgress = 0.0;
  String _loadingStatus = 'Đang kiểm tra dữ liệu...';

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _cacheService = ModelCacheService();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      // 1. Validate URL
      if (widget.product.model3DUrl == null || widget.product.model3DUrl!.isEmpty) {
        throw Exception('Sản phẩm chưa có dữ liệu 3D');
      }

      String url = widget.product.model3DUrl!;

      // 2. Xử lý URL
      if (!url.startsWith('http')) {
        url = _apiClient.getImageUrl(url);
      }
      url = Uri.encodeFull(url);
      if (url.startsWith('http://')) {
        url = url.replaceFirst('http://', 'https://');
      }

      // 3. Clean URL
      int extensionIndex = url.indexOf('.glb');
      if (extensionIndex != -1) {
        url = url.substring(0, extensionIndex + 4);
      }

      _remoteModelUrl = url;

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🎯 AR Setup: Downloading Model');
      debugPrint('URL: $_remoteModelUrl');

      // 4. Download và Cache
      setState(() {
        _loadingStatus = 'Đang tải dữ liệu 3D...';
        _downloadProgress = 0.0;
      });

      final localPath = await _cacheService.downloadAndCacheModel(
        productId: widget.product.id,
        modelUrl: url,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
              _loadingStatus = 'Đang tải ${(progress * 100).toStringAsFixed(0)}%';
            });
          }
        },
      );

      if (localPath == null) throw Exception('Lỗi kết nối mạng');

      // 5. Kiểm tra file tồn tại
      if (!await File(localPath).exists()) {
        throw Exception('File không tồn tại sau khi tải');
      }

      // 6. Hoàn tất
      if (mounted) {
        setState(() {
          _localModelPath = localPath;
          _isDownloading = false;
          _loadingStatus = 'Sẵn sàng!';
        });
      }
      debugPrint('✅ AR Ready. Local Path: $localPath');

    } catch (e) {
      debugPrint('❌ AR Init Error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _retryDownload() async {
    if (widget.product.model3DUrl == null) return;
    // Xóa cache cũ nếu lỗi
    await _cacheService.deleteCachedModel(widget.product.id);
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isDownloading = true;
    });
    _initializeModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Layer hiển thị (Loading / Error / AR Viewer)
          if (_hasError)
            _buildErrorView()
          else if (_isDownloading)
            _buildDownloadingView()
          else if (_localModelPath != null)
              _buildARViewer(),

          // 2. Layer hướng dẫn
          if (!_isDownloading && !_hasError)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildGuideOverlay(),
            ),
        ],
      ),
    );
  }

  // Màn hình Loading
  Widget _buildDownloadingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.product.images.isNotEmpty)
                Container(
                  height: 150,
                  width: 150,
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(_apiClient.getImageUrl(widget.product.images.first)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                    ),
                  ),
                ),

              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                _loadingStatus,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Màn hình Lỗi
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryDownload,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary500,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildARViewer() {
    // Tạo đường dẫn file local
    final localFileUrl = 'file://$_localModelPath';

    // Poster hiển thị trước khi model load xong
    final posterUrl = widget.product.images.isNotEmpty
        ? _apiClient.getImageUrl(widget.product.images.first)
        : '';

    return ModelViewer(
      // Key quan trọng để widget rebuild khi path thay đổi
      key: ValueKey(localFileUrl),

      // Load từ file trên máy (Cache)
      src: localFileUrl,
      alt: widget.product.name,
      poster: posterUrl,

      // Cấu hình AR
      ar: true,
      arModes: const ['scene-viewer', 'webxr', 'quick-look'], // Ưu tiên SceneViewer
      arPlacement: ArPlacement.floor, // Bắt buộc: Đặt xuống sàn
      arScale: ArScale.auto, // Tỉ lệ thực 1:1

      // Camera & Điều khiển
      cameraControls: true,
      autoRotate: true,

      // iOS Setup
      iosSrc: localFileUrl,

      backgroundColor: Colors.white,
      loading: Loading.eager,

      relatedCss: '''
        model-viewer > button[slot="ar-button"] {
          background-color: #FF9800;
          border-radius: 8px;
          border: none;
          color: white;
          position: absolute;
          top: 32px;
          right: 16px;
          padding: 12px 24px;
          font-family: sans-serif;
          font-size: 16px;
          font-weight: bold;
          box-shadow: 0 2px 4px rgba(0,0,0,0.25);
        }
      ''',
    );
  }

  // Widget hiển thị hướng dẫn
  Widget _buildGuideOverlay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_in_ar, color: AppTheme.primary500),
              const SizedBox(width: 10),
              const Text(
                'Chế độ AR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Bấm vào nút ở góc dưới bên phải model để mở Camera và đặt vật phẩm vào không gian thực.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}