import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart'; // Cần import User model
import 'package:flutter_application_1/services/database_helper.dart'; // Import DatabaseHelper

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  User? _loggedInUser;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loggedInUser == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bảo mật tài khoản',
          style: TextStyle(color: Colors.white),
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle('Lịch sử đăng nhập'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text(
                  'Xem lịch sử đăng nhập',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
                onTap: () {
                  _showSnackBar(
                    'Tính năng xem lịch sử đăng nhập sẽ sớm ra mắt',
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Đổi mật khẩu'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPasswordField(
                      _currentPasswordController,
                      'Mật khẩu hiện tại',
                      Icons.lock_outline,
                      _isCurrentPasswordVisible,
                      (value) {
                        setState(() {
                          _isCurrentPasswordVisible = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                      _newPasswordController,
                      'Mật khẩu mới',
                      Icons.vpn_key_outlined,
                      _isNewPasswordVisible,
                      (value) {
                        setState(() {
                          _isNewPasswordVisible = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                      _confirmNewPasswordController,
                      'Xác nhận mật khẩu mới',
                      Icons.vpn_key_outlined,
                      _isConfirmNewPasswordVisible,
                      (value) {
                        setState(() {
                          _isConfirmNewPasswordVisible = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Đổi mật khẩu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isVisible,
    ValueChanged<bool> onVisibilityToggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () => onVisibilityToggle(!isVisible),
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
    );
  }

  void _changePassword() async {
    if (_loggedInUser == null) {
      _showSnackBar('Không tìm thấy thông tin người dùng.');
      return;
    }

    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmNewPasswordController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ tất cả các trường.');
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      _showSnackBar('Mật khẩu mới và xác nhận mật khẩu không khớp.');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự.');
      return;
    }

    // Giả lập logic đổi mật khẩu
    // Trong thực tế, bạn sẽ gọi DatabaseHelper để xác thực mật khẩu cũ và cập nhật mật khẩu mới
    DatabaseHelper dbHelper = DatabaseHelper();
    User? authenticatedUser = await dbHelper.getUserByEmailAndPassword(
      _loggedInUser!.email,
      _currentPasswordController.text,
    );

    if (authenticatedUser != null) {
      // Mật khẩu hiện tại đúng, tiến hành cập nhật mật khẩu mới
      _loggedInUser!.password =
          _newPasswordController.text; // Trong thực tế: HASH mật khẩu này!
      int rowsAffected = await dbHelper.updateUser(_loggedInUser!);

      if (rowsAffected > 0) {
        _showSnackBar('Đổi mật khẩu thành công!');
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      } else {
        _showSnackBar('Có lỗi xảy ra khi đổi mật khẩu.');
      }
    } else {
      _showSnackBar('Mật khẩu hiện tại không đúng.');
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }
}
