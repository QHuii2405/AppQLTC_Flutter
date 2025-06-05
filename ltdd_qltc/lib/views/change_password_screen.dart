import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/models/user.dart'; // Import User model
import 'package:ltdd_qltc/controllers/auth_controller.dart'; // Import AuthController
import 'package:ltdd_qltc/views/login_history_screen.dart'; // Import LoginHistoryScreen

class ChangePasswordScreen extends StatefulWidget {
  final User user; // Nhận đối tượng User hiện tại
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

  Future<void> _changePassword() async {
    final authController = Provider.of<AuthController>(context, listen: false);

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmNewPassword = _confirmNewPasswordController.text;

    // Clear previous error message
    authController.clearErrorMessage();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmNewPassword.isEmpty) {
      authController.setErrorMessage('Vui lòng điền đầy đủ tất cả các trường.');
      return;
    }

    if (newPassword != confirmNewPassword) {
      authController.setErrorMessage(
        'Mật khẩu mới và xác nhận mật khẩu không khớp.',
      );
      return;
    }

    if (newPassword.length < 6) {
      authController.setErrorMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');
      return;
    }

    if (newPassword == currentPassword) {
      authController.setErrorMessage(
        'Mật khẩu mới không được trùng với mật khẩu hiện tại.',
      );
      return;
    }

    // Gọi phương thức đổi mật khẩu từ AuthController
    bool success = await authController.changePassword(
      widget.user.id!, // Truyền ID người dùng hiện tại
      currentPassword,
      newPassword,
      confirmNewPassword,
    );

    if (success) {
      _showSnackBar('Đổi mật khẩu thành công!');
      // Xóa các trường sau khi đổi mật khẩu thành công
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
      authController.clearErrorMessage(); // Xóa lỗi nếu có
      Navigator.pop(context); // Quay lại màn hình cài đặt
    } else {
      // Lỗi đã được AuthController xử lý và set errorMessage
      _showSnackBar(authController.errorMessage ?? 'Đổi mật khẩu thất bại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Đổi mật khẩu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF5CBDD9), // Màu nền AppBar
            iconTheme: const IconThemeData(
              color: Colors.white,
            ), // Màu icon trên AppBar
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)], // Gradient nền
              ),
            ),
            // Sử dụng SafeArea để tránh các phần tử bị che bởi notch/status bar
            child: SafeArea(
              // Sử dụng LayoutBuilder để lấy chiều cao khả dụng của body
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 40.0,
                    ),
                    child: ConstrainedBox(
                      // Đảm bảo Column chiếm ít nhất toàn bộ chiều cao khả dụng sau khi trừ padding
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - (40.0 * 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Đẩy nội dung lên và xuống
                        children: [
                          Column(
                            // Gộp các trường mật khẩu vào một Column con
                            children: [
                              // Mật khẩu hiện tại
                              _buildPasswordField(
                                controller: _currentPasswordController,
                                hintText: 'Mật khẩu hiện tại',
                                isVisible: _isCurrentPasswordVisible,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _isCurrentPasswordVisible =
                                        !_isCurrentPasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Mật khẩu mới
                              _buildPasswordField(
                                controller: _newPasswordController,
                                hintText: 'Mật khẩu mới',
                                isVisible: _isNewPasswordVisible,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _isNewPasswordVisible =
                                        !_isNewPasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Xác nhận mật khẩu mới
                              _buildPasswordField(
                                controller: _confirmNewPasswordController,
                                hintText: 'Xác nhận mật khẩu mới',
                                isVisible: _isConfirmNewPasswordVisible,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _isConfirmNewPasswordVisible =
                                        !_isConfirmNewPasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),

                          Column(
                            // Gộp các nút bấm vào một Column con
                            children: [
                              // Nút "Đổi mật khẩu"
                              ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  elevation: 5,
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
                                        'Đổi mật khẩu',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                height: 15,
                              ), // Khoảng cách giữa 2 nút
                              // Nút "Lịch sử đăng nhập"
                              OutlinedButton.icon(
                                onPressed: () {
                                  // Điều hướng đến màn hình lịch sử đăng nhập
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LoginHistoryScreen(user: widget.user),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.history,
                                  color: Colors.white70,
                                ),
                                label: const Text(
                                  'Lịch sử đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1,
                                  ), // Viền nút
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ), // Padding dọc
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ), // Khoảng cách dưới nút
                              // Hiển thị lỗi từ AuthController nếu có
                              if (authController.errorMessage != null &&
                                  authController.errorMessage!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    authController.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget riêng cho trường mật khẩu để tái sử dụng
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return SizedBox(
      height: 55,
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white60, fontSize: 15),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Colors.white70,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: onVisibilityToggle,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
