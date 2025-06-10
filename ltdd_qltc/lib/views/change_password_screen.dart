import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  final User user;
  const ChangePasswordScreen({super.key, required this.user});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.clearErrorMessage();

    bool success = await authController.changePassword(
      widget.user.id!,
      _currentPasswordController.text,
      _newPasswordController.text,
      _confirmNewPasswordController.text,
    );

    if (mounted) {
      if (success) {
        _showSnackBar('Đổi mật khẩu thành công!');
        Navigator.pop(context);
      } else {
        _showSnackBar(authController.errorMessage ?? 'Đổi mật khẩu thất bại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: const Color(0xFF5CBDD9),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPasswordField(
              controller: _currentPasswordController,
              labelText: 'Mật khẩu hiện tại',
              isVisible: _isCurrentPasswordVisible,
              onToggleVisibility: () => setState(
                () => _isCurrentPasswordVisible = !_isCurrentPasswordVisible,
              ),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              labelText: 'Mật khẩu mới',
              isVisible: _isNewPasswordVisible,
              onToggleVisibility: () => setState(
                () => _isNewPasswordVisible = !_isNewPasswordVisible,
              ),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmNewPasswordController,
              labelText: 'Xác nhận mật khẩu mới',
              isVisible: _isConfirmNewPasswordVisible,
              onToggleVisibility: () => setState(
                () => _isConfirmNewPasswordVisible =
                    !_isConfirmNewPasswordVisible,
              ),
            ),
            const SizedBox(height: 32),
            Consumer<AuthController>(
              builder: (context, authController, child) {
                return ElevatedButton(
                  onPressed: authController.isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: authController.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đổi mật khẩu'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
