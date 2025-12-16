import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  bool _isLoading = false;
  String _sentToEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    // Validate email
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.forgotPassword(email: email);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          setState(() {
            _sentToEmail = email;
            _emailSent = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Có lỗi xảy ra'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã có lỗi xảy ra: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.forgotPassword(email: _sentToEmail);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi lại email khôi phục'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Có lỗi xảy ra'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã có lỗi xảy ra: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beige50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                Text(
                  'FurniShop',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary500,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Khôi phục mật khẩu',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.char600,
                  ),
                ),
                const SizedBox(height: 48),

                // Content Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _emailSent
                      ? _buildEmailSentContent()
                      : _buildEmailInputContent(),
                ),
                const SizedBox(height: 24),

                // Back to Login Link
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: AppTheme.primary500,
                  ),
                  label: Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primary500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInputContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Instruction Text
        Text(
          'Nhập email đã đăng ký, chúng tôi sẽ gửi hướng dẫn khôi phục mật khẩu cho bạn.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.char700,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Email Label
        Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary500,
          ),
        ),
        const SizedBox(height: 8),

        // Email Input
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'your@email.com',
            hintStyle: TextStyle(
              color: AppTheme.char400,
            ),
            filled: true,
            fillColor: AppTheme.beige50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.char200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.primary500,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Send Email Button
        ElevatedButton(
          onPressed: _isLoading ? null : _sendResetEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Gửi email khôi phục',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        ],
      ),
    );
  }

  Widget _buildEmailSentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: AppTheme.success,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Kiểm tra email của bạn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.char900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Confirmation Message
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.char700,
              height: 1.5,
            ),
            children: [
              const TextSpan(
                text: 'Chúng tôi đã gửi hướng dẫn khôi phục mật khẩu đến email ',
              ),
              TextSpan(
                text: _sentToEmail,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.char900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Resend Instructions
        Text(
          'Không nhận được email? Kiểm tra thư mục spam hoặc',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.char600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Resend Email Button
        OutlinedButton(
          onPressed: _isLoading ? null : _resendEmail,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary500,
            side: BorderSide(color: AppTheme.primary500, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.primary500,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Gửi lại email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
