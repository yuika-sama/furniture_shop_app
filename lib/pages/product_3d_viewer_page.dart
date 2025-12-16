import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../constants/app_theme.dart';
import '../models/product_model.dart';
import '../service/api_client.dart';
import '../service/model_cache_service.dart';

class Product3DViewerPage extends StatefulWidget {
  final ProductModel product;

  const Product3DViewerPage({
    super.key,
    required this.product,
  });

  @override
  State<Product3DViewerPage> createState() => _Product3DViewerPageState();
}

class _Product3DViewerPageState extends State<Product3DViewerPage> {
  late final ApiClient _apiClient;
  late final ModelCacheService _cacheService;
  
  bool _isDownloading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _localModelPath;
  String? _remoteModelUrl;
  double _downloadProgress = 0.0;
  String _loadingStatus = 'Đang kiểm tra cache...';
  int _resetCounter = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _cacheService = ModelCacheService();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      // 1. Validate model URL
      if (widget.product.model3DUrl == null || widget.product.model3DUrl!.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Sản phẩm không có model 3D';
          _isDownloading = false;
        });
        return;
      }

      String url = widget.product.model3DUrl!;

      // 2. Build full URL
      if (!url.startsWith('http')) {
        url = _apiClient.getImageUrl(url);
      }

      // 3. Encode URL
      url = Uri.encodeFull(url);
      if (url.startsWith('http://')) {
        url = url.replaceFirst('http://', 'https://');
      }
      int extensionIndex = url.indexOf('.glb');

            if (extensionIndex != -1) {
              url = url.substring(0, extensionIndex + 4);
            }

      _remoteModelUrl = url;

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🎯 Initializing 3D Model');
      debugPrint('Product: ${widget.product.name}');
      debugPrint('Product ID: ${widget.product.id}');
      debugPrint('Remote URL: $_remoteModelUrl');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 4. Download và cache model
      setState(() {
        _loadingStatus = 'Đang tải model 3D...';
        _downloadProgress = 0.0;
      });

      final localPath = await _cacheService.downloadAndCacheModel(
        productId: widget.product.id,
        modelUrl: url,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
            _loadingStatus = 'Đang tải ${(progress * 100).toStringAsFixed(0)}%';
          });
        },
      );

      if (localPath == null) {
        throw Exception('Không thể tải model 3D. Vui lòng kiểm tra kết nối mạng.');
      }

      // 5. Verify file exists
      final file = File(localPath);
      if (!await file.exists()) {
        throw Exception('File model không tồn tại sau khi tải');
      }

      setState(() {
        _localModelPath = localPath;
        _isDownloading = false;
        _loadingStatus = 'Model đã sẵn sàng!';
      });

      debugPrint('✅ Model ready at: $localPath');

    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing model: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isDownloading = false;
      });
    }
  }

  Future<void> _redownloadModel() async {
    // Xóa cache cũ và download lại
    await _cacheService.deleteCachedModel(widget.product.id);
    setState(() {
      _localModelPath = null;
      _hasError = false;
      _errorMessage = null;
      _isDownloading = true;
    });
    await _initializeModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.product.name,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              _showProductInfo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showGuide();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 3D Viewer Area
          if (_hasError)
            _buildErrorView()
          else if (_isDownloading)
            _buildDownloadingView()
          else if (_localModelPath != null)
            _build3DViewer(),
          
          // Controls overlay
          if (!_hasError && !_isDownloading && _localModelPath != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildControls(),
            ),
        ],
      ),
    );
  }

  Widget _buildDownloadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Icons.download_for_offline,
              size: 80,
              color: AppTheme.primary500,
            ),
            const SizedBox(height: 24),
            
            // Status text
            Text(
              _loadingStatus,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Progress bar
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _downloadProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info text
            Text(
              'Model 3D sẽ được lưu trữ để xem nhanh hơn lần sau',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'Không thể tải model 3D',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _redownloadModel,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary500,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DViewer() {
    if (_localModelPath == null) {
      return _buildDownloadingView();
    }

    final posterUrl = widget.product.images.isNotEmpty 
        ? _apiClient.getImageUrl(widget.product.images.first)
        : '';
    
    // Sử dụng file:// scheme cho local file
    final localFileUrl = 'file://$_localModelPath';
    
    return ModelViewer(
      key: ValueKey('${_localModelPath}_$_resetCounter'),
      src: localFileUrl,
      alt: widget.product.name,
      poster: posterUrl,
      loading: Loading.eager,
      reveal: Reveal.auto,
      autoPlay: true,
      
      // AR & Interaction
      ar: true,
      arModes: const ['scene-viewer', 'webxr', 'quick-look'],
      autoRotate: false,
      cameraControls: true,
      disableZoom: false,
      touchAction: TouchAction.panY,
      
      // Camera settings
      cameraOrbit: '0deg 75deg 105%',
      minCameraOrbit: 'auto auto 5%',
      maxCameraOrbit: 'auto auto 500%',
      fieldOfView: '30deg',
      
      // Environment & Lighting
      backgroundColor: Colors.white,
      shadowIntensity: 1.0,
      shadowSoftness: 0.8,
      exposure: 1.0,
      
      // Interaction prompts
      interactionPrompt: InteractionPrompt.auto,
      interactionPromptThreshold: 2000,
      
      // iOS compatibility
      iosSrc: widget.product.model3DUrl!,
      
      // Debug
      onWebViewCreated: (controller) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('✅ 3D Model Viewer WebView Created');
        debugPrint('📦 Local Model Path: $_localModelPath');
        debugPrint('🖼️ Poster URL: $posterUrl');
        debugPrint('📱 Product: ${widget.product.name}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      },
      
      // Custom HTML/CSS
      relatedCss: '''
        model-viewer {
          width: 100%;
          height: 100%;
          --poster-color: transparent;
          --progress-bar-color: #8B6F47;
          --progress-bar-height: 4px;
        }
        
        model-viewer::part(default-progress-bar) {
          background-color: #8B6F47;
          border-radius: 2px;
        }
        
        model-viewer::part(default-progress-mask) {
          background: rgba(0, 0, 0, 0.3);
        }
      ''',
      
      relatedJs: '''
        const modelViewer = document.querySelector('model-viewer');
        
        if (!modelViewer) {
          console.error('Model viewer element not found');
        } else {
          console.log('Model viewer initialized');
          console.log('Model src:', modelViewer.src);
          
          modelViewer.addEventListener('load', () => {
            console.log('Model loaded successfully from local file!');
          });
          
          modelViewer.addEventListener('error', (event) => {
            console.error('Model loading error:', event);
          });
          
          modelViewer.addEventListener('progress', (event) => {
            const progress = (event.detail.totalProgress * 100).toFixed(0);
            console.log('Rendering progress:', progress + '%');
          });
        }
      ''',
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info text
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Kéo để xoay • Pinch để zoom',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Debug info
                if (_localModelPath != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onLongPress: () {
                      // Show debug info on long press
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Debug Info'),
                          content: SelectableText(
                            'Product ID:\n${widget.product.id}\n\n'
                            'Local Path:\n$_localModelPath\n\n'
                            'Remote URL:\n$_remoteModelUrl\n\n'
                            'Status:\n$_loadingStatus'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Đóng'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[300],
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Model đã cache • Nhấn giữ để xem info',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Force rebuild ModelViewer
                      setState(() {
                        _resetCounter++;
                      });
                
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã reset góc nhìn về mặc định'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showProductInfo,
                    icon: const Icon(Icons.info, size: 20),
                    label: const Text('Thông tin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Thông tin sản phẩm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.char900,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Product name
            Text(
              widget.product.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.char900,
              ),
            ),
            const SizedBox(height: 8),
            
            // Category
            if (widget.product.category != null)
              Text(
                widget.product.category!.name,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.char600,
                ),
              ),
            const SizedBox(height: 16),
            
            // Price
            Row(
              children: [
                Icon(Icons.attach_money, color: AppTheme.primary500, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Giá tiền:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.char600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.product.price.toStringAsFixed(0)} đ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary500,
                  ),
                ),
              ],
            ),
            
            if (widget.product.hasDiscount && widget.product.originalPrice != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 28),
                  Text(
                    'Giá gốc:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.char400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.product.originalPrice!.toStringAsFixed(0)} đ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.char400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
            
            // Dimensions
            if (widget.product.dimensions != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.straighten, color: AppTheme.primary500, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kích thước:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.char600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDimensionRow('Chiều rộng', '${widget.product.dimensions!.width} cm'),
              _buildDimensionRow('Chiều cao', '${widget.product.dimensions!.height} cm'),
              _buildDimensionRow('Chiều dài', '${widget.product.dimensions!.length} cm'),
            ],
            
            // Materials
            if (widget.product.materials.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.category, color: AppTheme.primary500, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Chất liệu:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.char600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.product.materials.map((material) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.beige100,
                      border: Border.all(color: AppTheme.beige200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      material,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.char800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.char600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.char900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showGuide() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hướng dẫn sử dụng 3D Viewer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGuideItem(Icons.pan_tool, 'Kéo 1 ngón tay', 'Xoay model 3D theo mọi hướng'),
            _buildGuideItem(Icons.zoom_in, 'Pinch (2 ngón)', 'Zoom in/out để xem chi tiết'),
            _buildGuideItem(Icons.refresh, 'Nút Reset', 'Đưa model về góc nhìn ban đầu'),
            _buildGuideItem(Icons.info, 'Nút Thông tin', 'Xem thông tin chi tiết sản phẩm'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary500,
                ),
                child: const Text('Đã hiểu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary500, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.char600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
