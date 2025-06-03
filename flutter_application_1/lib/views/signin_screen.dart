import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart'; // Đảm bảo đường dẫn chính xác
import 'package:flutter_application_1/models/user.dart'; // Import User model

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isSignInMode = true; // true for Sign In, false for Sign Up

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
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
                    padding: EdgeInsets.only(top: 40, bottom: 40),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _isSignInMode ? 'Welcome Back!' : 'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          _isSignInMode
                              ? 'Sign in to your account'
                              : 'Join EWallet today',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Social Login Buttons
                  _buildGoogleButton(),
                  SizedBox(height: 12),
                  _buildFacebookButton(),

                  // Divider
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white30, thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with email',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white30, thickness: 1),
                        ),
                      ],
                    ),
                  ),

                  // Form Fields
                  if (!_isSignInMode) ...[
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 16),
                  ],
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  _buildPasswordField(),

                  // Forgot Password (only in sign in mode)
                  if (_isSignInMode) ...[
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: _showForgotPasswordDialog,
                        child: Text(
                          'Forgot Password?',
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

                  SizedBox(height: 30),

                  // Main Action Button
                  _buildMainActionButton(),

                  // Switch Mode Link
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignInMode
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignInMode = !_isSignInMode;
                              _clearForm();
                            });
                          },
                          child: Text(
                            _isSignInMode ? 'Sign Up' : 'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _showFeatureNotAvailable();
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
              child: Icon(Icons.g_mobiledata, color: Colors.white, size: 14),
            ),
            SizedBox(width: 12),
            Text(
              'Continue with Google',
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
          _showFeatureNotAvailable();
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
                color: Color(0xFF1877F2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.facebook, color: Colors.white, size: 14),
            ),
            SizedBox(width: 12),
            Text(
              'Continue with Facebook',
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
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white, width: 2),
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
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.white70, size: 20),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildMainActionButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_isSignInMode ? _signIn : _signUp),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  _isSignInMode ? 'Sign In' : 'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  void _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ email và mật khẩu.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseHelper dbHelper = DatabaseHelper();

      // SỬ DỤNG getUserByEmailAndPassword để trả về đối tượng User
      User? user = await dbHelper.getUserByEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        _showSnackBar('Chào mừng trở lại!');

        // Điều hướng đến home screen VỚI ĐỐI TƯỢNG USER
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: user, // TRUYỀN ĐỐI TƯỢNG USER ĐÃ LẤY ĐƯỢC
          );
        });
      } else {
        _showSnackBar('Email hoặc mật khẩu không hợp lệ.');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi đăng nhập: $e');
      print('Lỗi đăng nhập: $e'); // In lỗi ra console để debug
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ tất cả các trường.');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseHelper dbHelper = DatabaseHelper();

      // Kiểm tra xem email đã tồn tại chưa
      bool emailExists = await dbHelper.checkEmailExists(_emailController.text);
      if (emailExists) {
        _showSnackBar('Email đã tồn tại.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Tạo đối tượng User mới
      User newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text, // Trong thực tế: HASH mật khẩu này!
        createdAt: DateTime.now().toIso8601String(),
        profileImageUrl: null, // Mặc định là null khi đăng ký
      );

      // Chèn đối tượng User vào database
      await dbHelper.insertUser(newUser);
      _showSnackBar('Tài khoản đã được tạo thành công!');

      // Chuyển sang chế độ đăng nhập
      setState(() {
        _isSignInMode = true;
        _clearForm();
      });
    } catch (e) {
      _showSnackBar('Lỗi khi tạo tài khoản: $e');
      print('Lỗi tạo tài khoản: $e'); // In lỗi ra console để debug
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Đặt lại mật khẩu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nhập địa chỉ email của bạn để nhận mã đặt lại.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Địa chỉ Email',
                    prefixIcon: Icon(Icons.email_outlined),
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
                child: Text('Hủy'),
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
                  await _requestPasswordReset(resetEmailController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5CBDD9),
                ),
                child: Text(
                  'Gửi mã đặt lại',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _requestPasswordReset(String email) async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      String? resetToken = await dbHelper.createResetToken(email);

      if (resetToken != null) {
        _showSnackBar('Mã đặt lại đã được gửi! Kiểm tra thông báo của bạn.');

        // Hiển thị mã reset (trong thực tế, mã này sẽ được gửi qua email/SMS)
        _showResetCodeDialog(resetToken, email);
      } else {
        _showSnackBar('Không tìm thấy địa chỉ email.');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi gửi mã đặt lại: $e');
      print('Lỗi gửi mã đặt lại: $e');
    }
  }

  void _showResetCodeDialog(String resetCode, String email) {
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    // Hiển thị mã reset trong console/debug (chỉ để test)
    print('Mã đặt lại cho $email: $resetCode');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    'Nhập mã đặt lại',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
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
                        SizedBox(height: 20),
                        TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Nhập mã 6 chữ số',
                            prefixIcon: Icon(Icons.security),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: newPasswordController,
                          obscureText: !isNewPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Mật khẩu mới',
                            prefixIcon: Icon(Icons.lock_outline),
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
                        SizedBox(height: 16),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Xác nhận mật khẩu',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
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
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _resetPassword(
                          email,
                          codeController.text,
                          newPasswordController.text,
                          confirmPasswordController.text,
                        );
                        Navigator.pop(context); // Đóng dialog sau khi xử lý
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5CBDD9),
                      ),
                      child: Text(
                        'Đặt lại mật khẩu',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _resetPassword(
    String email,
    String code,
    String newPassword,
    String confirmPassword,
  ) async {
    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ tất cả các trường.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Mật khẩu không khớp.');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      bool success = await dbHelper.resetPassword(email, code, newPassword);

      if (success) {
        _showSnackBar(
          'Mật khẩu đã được đặt lại thành công! Bây giờ bạn có thể đăng nhập.',
        );
        _clearForm();
      } else {
        _showSnackBar('Mã đặt lại không hợp lệ hoặc đã hết hạn.');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi đặt lại mật khẩu: $e');
      print('Lỗi đặt lại mật khẩu: $e');
    }
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

  void _showFeatureNotAvailable() {
    _showSnackBar('Tính năng này sẽ sớm khả dụng');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
