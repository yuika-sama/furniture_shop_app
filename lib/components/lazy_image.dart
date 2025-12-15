import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Lazy loading image component with placeholder and error handling
class LazyImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return _buildErrorWidget();
    }

    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ?? _buildPlaceholder(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget();
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(ImageChunkEvent? loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.beige100,
      child: Center(
        child: loadingProgress != null &&
                loadingProgress.expectedTotalBytes != null
            ? CircularProgressIndicator(
                value: loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!,
                strokeWidth: 2,
                color: AppTheme.primary500,
              )
            : const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary500,
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.beige100,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : 48,
        color: AppTheme.char300,
      ),
    );
  }
}
