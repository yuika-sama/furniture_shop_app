import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Error Boundary Widget
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? errorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Global Error Handler 
  static Widget buildErrorScreen({
    required BuildContext context,
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return Scaffold(
      backgroundColor: AppTheme.beige50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title ?? 'Đã xảy ra lỗi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.char900,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message ?? 'Vui lòng thử lại sau',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.char600,
                    ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading Screen Widget
class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beige50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary500),
            ),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.char600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network Error Widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: AppTheme.char400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có kết nối mạng',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng kiểm tra kết nối internet và thử lại',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.char200.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: AppTheme.char500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// App State Widget
class AppStateWrapper extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;
  final String? loadingMessage;

  const AppStateWrapper({
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingScreen(message: loadingMessage);
    }

    if (hasError) {
      return ErrorBoundary.buildErrorScreen(
        context: context,
        message: errorMessage,
        onRetry: onRetry,
      );
    }

    return child;
  }
}
