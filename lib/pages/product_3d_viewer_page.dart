import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../constants/app_theme.dart';
import '../models/product_model.dart';
import '../service/api_client.dart';

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
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _fullModelUrl;
  String _loadingStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _validateModel();
  }

  void _handleJavaScriptMessage(String message) {
    debugPrint('📱 JS Message: $message');
    
    if (message.startsWith('ERROR:')) {
      setState(() {
        _hasError = true;
        _errorMessage = message.replaceFirst('ERROR:', '').trim();
      });
    } else if (message.startsWith('STATUS:')) {
      setState(() {
        _loadingStatus = message.replaceFirst('STATUS:', '').trim();
      });
    } else if (message == 'LOADED') {
      setState(() {
        _isLoading = false;
      });
      debugPrint('✅ Model loaded successfully via JS channel!');
    }
  }

  void _validateModel() {
    if (widget.product.model3DUrl == null || widget.product.model3DUrl!.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Sản phẩm không có model 3D';
      });
      return;
    }

    String url = widget.product.model3DUrl!;

    // 1. Xử lý Relative URL
    if (!url.startsWith('http')) {
      url = _apiClient.getImageUrl(url);
    }

    // 2. FIX QUAN TRỌNG: Encode URL để xử lý khoảng trắng hoặc ký tự đặc biệt
    // Ví dụ: "file name.glb" -> "file%20name.glb"
    url = Uri.encodeFull(url);

    // 3. Fix Cloudinary logic (Cải tiến)
    // Cloudinary thường trả về http, nên đổi sang https để tránh lỗi Mixed Content
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }

    // Xử lý chuyển đổi resource_type từ image sang raw cho file .glb trên Cloudinary
    if (url.contains('cloudinary.com')) {
      if (url.contains('/image/upload/')) {
        url = url.replaceAll('/image/upload/', '/raw/upload/');
      } else if (url.contains('/video/upload/')) {
        // Đôi khi user upload nhầm vào video
        url = url.replaceAll('/video/upload/', '/raw/upload/');
      }
    }

    _fullModelUrl = url;

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔍 Model URL Validation');
    debugPrint('Original: ${widget.product.model3DUrl}');
    debugPrint('Final URL: $_fullModelUrl');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Validate format (Chấp nhận cả chữ hoa chữ thường)
    final lowerUrl = url.toLowerCase();
    if (!lowerUrl.contains('.glb') && !lowerUrl.contains('.gltf')) {
      // Warning nhẹ nhưng vẫn cho chạy thử, vì có thể URL không hiện đuôi file
      debugPrint('⚠️ Cảnh báo: URL không chứa đuôi .glb hoặc .gltf');
    }
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
          else
            _build3DViewer(),
          
          // Controls overlay
          if (!_hasError)
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

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Đang tải model 3D...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
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
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary500,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DViewer() {
    // Sử dụng ảnh đầu tiên của sản phẩm làm poster với full URL
    final posterUrl = widget.product.images.isNotEmpty 
        ? _apiClient.getImageUrl(widget.product.images.first)
        : '';
    
    return ModelViewer(
      key: ValueKey(_fullModelUrl),
      src: _fullModelUrl ?? widget.product.model3DUrl!,
      alt: widget.product.name,
      poster: posterUrl, // Hiển thị ảnh sản phẩm trong lúc load
      loading: Loading.eager, // Eager để load ngay
      reveal: Reveal.auto, // Auto reveal khi sẵn sàng
      autoPlay: true, 
      
      // WebView debugging
      debugLogging: true,
      javascriptChannels: {
        JavascriptChannel(
          'FlutterChannel',
          onMessageReceived: (message) {
            _handleJavaScriptMessage(message.message);
          },
        ),
      },
      
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
      backgroundColor: Colors.transparent,
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
        debugPrint('📦 Model URL: $_fullModelUrl');
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
        function sendToFlutter(message) {
          if (window.FlutterChannel) {
            FlutterChannel.postMessage(message);
          }
        }
        
        sendToFlutter('STATUS:Initializing ModelViewer...');
        
        const modelViewer = document.querySelector('model-viewer');
        
        if (!modelViewer) {
          sendToFlutter('ERROR:Model viewer element not found');
        } else {
          sendToFlutter('STATUS:Model viewer element found');
          sendToFlutter('STATUS:Model URL: ' + modelViewer.src);
          
          modelViewer.addEventListener('load', () => {
            sendToFlutter('LOADED');
            sendToFlutter('STATUS:Model loaded successfully!');
          });
          
          modelViewer.addEventListener('error', (event) => {
            const errorMsg = 'Model loading failed: ' + (event.message || event.type || 'Unknown error');
            sendToFlutter('ERROR:' + errorMsg);
          });
          
          modelViewer.addEventListener('progress', (event) => {
            const progress = (event.detail.totalProgress * 100).toFixed(0);
            sendToFlutter('STATUS:Loading ' + progress + '%');
          });
          
          modelViewer.addEventListener('model-visibility', (event) => {
            sendToFlutter('STATUS:Model visibility: ' + event.detail.visible);
          });
          
          // Check if model file is accessible
          fetch(modelViewer.src, { method: 'HEAD' })
            .then(response => {
              if (response.ok) {
                sendToFlutter('STATUS:Model file accessible (HTTP ' + response.status + ')');
              } else {
                sendToFlutter('ERROR:Model file returned HTTP ' + response.status + ': ' + response.statusText);
              }
            })
            .catch(error => {
              sendToFlutter('ERROR:Cannot reach model file: ' + error.message);
            });
          
          // Timeout check
          setTimeout(() => {
            if (!modelViewer.loaded) {
              sendToFlutter('ERROR:Model loading timeout after 30 seconds');
            }
          }, 30000);
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
                if (_fullModelUrl != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onLongPress: () {
                      // Show full URL on long press
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Debug Info'),
                          content: SelectableText(
                            'Model URL:\n$_fullModelUrl\n\n'
                            'Status:\n$_loadingStatus\n\n'
                            'Has Error: $_hasError\n'
                            'Error Message: ${_errorMessage ?? "None"}'
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
                            _isLoading ? Icons.downloading : Icons.check_circle,
                            color: _hasError ? Colors.red[300] : Colors.white60,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _loadingStatus,
                              style: TextStyle(
                                color: _hasError ? Colors.red[300] : Colors.white60,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      // Force rebuild ModelViewer to reset camera
                      setState(() {
                        _hasError = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã reset góc nhìn'),
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
