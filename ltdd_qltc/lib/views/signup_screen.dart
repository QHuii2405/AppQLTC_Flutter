import 'package:flutter/material.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:provider/provider.dart'; // Import Provider

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController =
      TextEditingController(); // Controller cho trường Tên đầy đủ
  bool _isPasswordVisible = false;
  bool _isSignInMode = true; // true for Sign In, false for Sign Up

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose(); // Dispose name controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe trạng thái từ AuthController
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Scaffold(
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.only(top: 40, bottom: 40),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _isSignInMode
                                  ? 'Chào mừng trở lại!'
                                  : 'Tạo tài khoản', // Tiêu đề thay đổi
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSignInMode
                                  ? 'Đăng nhập vào tài khoản của bạn'
                                  : 'Tham gia EWallet ngay hôm nay', // Mô tả thay đổi
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Social Login Buttons
                      _buildGoogleButton(),
                      const SizedBox(height: 12),
                      _buildFacebookButton(),

                      // Divider
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 25),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Colors.white30,
                                thickness: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'hoặc tiếp tục với email',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Colors.white30,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Fields
                      // BẮT ĐẦU CÁC TRƯỜNG ĐĂNG KÝ
                      if (!_isSignInMode) ...[
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Tên đầy đủ',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // KẾT THÚC CÁC TRƯỜNG ĐĂNG KÝ
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Địa chỉ Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),

                      // Forgot Password (only in sign in mode)
                      if (_isSignInMode) ...[
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: _showForgotPasswordDialog,
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Main Action Button
                      _buildMainActionButton(
                        authController,
                      ), // Truyền authController
                      // Hiển thị lỗi từ AuthController
                      if (authController.errorMessage != null &&
                          authController.errorMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
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

                      // Switch Mode Link (Đăng nhập <-> Đăng ký)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSignInMode
                                  ? "Chưa có tài khoản? "
                                  : 'Đã có tài khoản? ',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSignInMode = !_isSignInMode;
                                  _clearForm();
                                  authController
                                      .clearErrorMessage(); // Xóa lỗi khi chuyển đổi chế độ
                                });
                              },
                              child: Text(
                                _isSignInMode
                                    ? 'Đăng ký'
                                    : 'Đăng nhập', // Văn bản liên kết thay đổi
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _showSnackBar('Tính năng này sẽ sớm khả dụng');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.g_mobiledata, // Sử dụng g_mobiledata cho Google
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tiếp tục với Google',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacebookButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _showSnackBar('Tính năng này sẽ sớm khả dụng');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.facebook, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tiếp tục với Facebook',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white60, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
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

  Widget _buildPasswordField() {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Mật khẩu',
          hintStyle: const TextStyle(color: Colors.white60, fontSize: 15),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Colors.white70,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
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

  Widget _buildMainActionButton(AuthController authController) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: authController.isLoading
            ? null
            : () => _handleAuth(authController),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
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
            : Text(
                _isSignInMode
                    ? 'Đăng nhập'
                    : 'Tạo tài khoản', // Văn bản nút thay đổi
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // Phương thức xử lý đăng nhập hoặc đăng ký
  void _handleAuth(AuthController authController) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text; // Lấy tên nếu ở chế độ đăng ký

    // Validation
    if (email.isEmpty || password.isEmpty || (!_isSignInMode && name.isEmpty)) {
      authController.setErrorMessage('Vui lòng điền đầy đủ thông tin.');
      return;
    }

    if (!_isValidEmail(email)) {
      authController.setErrorMessage('Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }

    if (password.length < 6) {
      authController.setErrorMessage('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    User? user;
    if (_isSignInMode) {
      // Logic ĐĂNG NHẬP
      user = await authController.signIn(email, password);
    } else {
      // Logic ĐĂNG KÝ
      user = await authController.signUp(name, email, password);
    }

    if (user != null) {
      _showSnackBar(
        _isSignInMode
            ? 'Chào mừng trở lại!'
            : 'Tài khoản đã được tạo thành công!', // Thông báo thành công khác nhau
      );
      // Điều hướng đến home screen VỚI ĐỐI TƯỢNG USER
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: user, // TRUYỀN ĐỐI TƯỢNG USER ĐÃ LẤY ĐƯỢC
        );
      });
    } else {
      // Lỗi đã được AuthController xử lý và set errorMessage
      // SnackBar sẽ hiển thị thông báo lỗi từ AuthController
      _showSnackBar(
        authController.errorMessage ?? 'Đã xảy ra lỗi không xác định.',
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Đặt lại mật khẩu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập địa chỉ email của bạn để nhận mã đặt lại.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Địa chỉ Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resetEmailController.text.isEmpty) {
                _showSnackBar('Vui lòng nhập địa chỉ email của bạn.');
                return;
              }
              if (!_isValidEmail(resetEmailController.text)) {
                _showSnackBar('Vui lòng nhập địa chỉ email hợp lệ.');
                return;
              }

              Navigator.pop(context);
              // Gọi phương thức forgotPassword từ AuthController
              final authController = Provider.of<AuthController>(
                context,
                listen: false,
              );
              String? resetToken = await authController.forgotPassword(
                resetEmailController.text,
              );

              if (resetToken != null) {
                _showSnackBar(
                  'Mã đặt lại đã được gửi! Kiểm tra thông báo của bạn.',
                );
                _showResetCodeDialog(resetToken, resetEmailController.text);
              } else {
                _showSnackBar(
                  authController.errorMessage ??
                      'Không tìm thấy địa chỉ email hoặc lỗi.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5CBDD9),
            ),
            child: const Text(
              'Gửi mã đặt lại',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetCodeDialog(String resetCode, String email) {
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    print('Mã đặt lại cho $email: $resetCode'); // Chỉ để debug

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Nhập mã đặt lại',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mã đặt lại: $resetCode\n(Có hiệu lực trong 15 phút)',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã 6 chữ số',
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: !isNewPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu mới',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isNewPasswordVisible = !isNewPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Gọi phương thức resetPassword từ AuthController
                final authController = Provider.of<AuthController>(
                  context,
                  listen: false,
                );
                bool success = await authController.resetPassword(
                  email,
                  codeController.text,
                  newPasswordController.text,
                  confirmPasswordController.text,
                );
                Navigator.pop(context); // Đóng dialog sau khi xử lý
                if (success) {
                  _showSnackBar(
                    'Mật khẩu đã được đặt lại thành công! Bây giờ bạn có thể đăng nhập.',
                  );
                  _clearForm();
                } else {
                  _showSnackBar(
                    authController.errorMessage ??
                        'Mã đặt lại không hợp lệ hoặc đã hết hạn.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5CBDD9),
              ),
              child: const Text(
                'Đặt lại mật khẩu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
