// screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _isEmailSent = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _sendResetToken() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      authController.setErrorMessage('Vui lòng nhập địa chỉ email.');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      authController.setErrorMessage('Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }

    bool success = await authController.sendResetToken(email);

    if (mounted) {
      if (success) {
        setState(() {
          _isEmailSent = true;
        });
        _showSnackBar(authController.errorMessage!); // Display message from controller
      } else {
        _showSnackBar(authController.errorMessage ?? 'Đã có lỗi xảy ra.');
      }
    }
  }

  Future<void> _resetPassword() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (token.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      authController.setErrorMessage('Vui lòng điền đầy đủ thông tin.');
      return;
    }
    if (newPassword.length < 6) {
      authController.setErrorMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');
      return;
    }
    if (newPassword != confirmNewPassword) {
      authController.setErrorMessage('Mật khẩu mới và xác nhận không khớp.');
      return;
    }

    bool success = await authController.resetPasswordWithToken(
      email,
      token,
      newPassword,
      confirmNewPassword,
    );

    if (mounted) {
      if (success) {
        _showSnackBar(authController.errorMessage!); // Display success message
        Navigator.pop(context); // Go back to login screen
      } else {
        _showSnackBar(authController.errorMessage ?? 'Đã có lỗi xảy ra.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isEmailSent ? 'Đặt lại mật khẩu' : 'Quên mật khẩu',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5CBDD9),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      _isEmailSent
                          ? 'Nhập mã và mật khẩu mới'
                          : 'Nhập email của bạn để đặt lại mật khẩu',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Địa chỉ Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isEmailSent, // Disable email field after sending token
                    ),
                    const SizedBox(height: 16),
                    if (!_isEmailSent)
                      ElevatedButton(
                        onPressed:
                            authController.isLoading ? null : _sendResetToken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authController.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Gửi mã đặt lại',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    if (_isEmailSent) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _tokenController,
                        hintText: 'Mã đặt lại (6 chữ số)',
                        icon: Icons.vpn_key_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        hintText: 'Mật khẩu mới',
                        isVisible: _isNewPasswordVisible,
                        toggleVisibility: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _confirmNewPasswordController,
                        hintText: 'Xác nhận mật khẩu mới',
                        isVisible: _isConfirmNewPasswordVisible,
                        toggleVisibility: () {
                          setState(() {
                            _isConfirmNewPasswordVisible =
                                !_isConfirmNewPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed:
                            authController.isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authController.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Đặt lại mật khẩu',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                    if (authController.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          authController.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(color: enabled ? Colors.white : Colors.white54),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: enabled ? Colors.white70 : Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}