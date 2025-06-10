import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/models/user.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSignInMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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

  Future<void> _handleAuth() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();

    authController.clearErrorMessage();

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
    if (!_isSignInMode && password != confirmPassword) {
      authController.setErrorMessage('Mật khẩu xác nhận không khớp.');
      return;
    }

    User? user;
    if (_isSignInMode) {
      user = await authController.signIn(email, password);
    } else {
      user = await authController.signUp(name, email, password);
    }

    if (mounted && user != null) {
      _showSnackBar(
        _isSignInMode ? 'Đăng nhập thành công!' : 'Tạo tài khoản thành công!',
      );
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    } else if (mounted) {
      _showSnackBar(authController.errorMessage ?? 'Đã có lỗi xảy ra.');
    }
  }

  void _handleForgotPassword() {
    _showSnackBar('Chức năng Quên mật khẩu đang được phát triển!');
    print('Forgot Password button pressed!'); // For debugging
  }

  // New handler for Google sign-in
  void _handleGoogleSignIn() {
    _showSnackBar('Đăng nhập với Google đang được phát triển!');
    print('Continue with Google pressed!'); // For debugging
  }

  // New handler for Facebook sign-in
  void _handleFacebookSignIn() {
    _showSnackBar('Đăng nhập với Facebook đang được phát triển!');
    print('Continue with Facebook pressed!'); // For debugging
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Icon placeholder based on your images
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.2,
                          ), // Slightly transparent white
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Rounded corners
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined, // Wallet icon
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isSignInMode ? 'Chào mừng trở lại!' : 'Tạo tài khoản',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8), // Smaller gap
                    Text(
                      _isSignInMode
                          ? 'Đăng nhập vào tài khoản của bạn'
                          : 'Tham gia EWallet ngay hôm nay',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Google Sign-in Button
                    _buildSocialSignInButton(
                      text: 'Tiếp tục với Google',
                      iconAsset: 'assets/images/google_logo.png',
                      onPressed: _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 16),
                    // Facebook Sign-in Button
                    _buildSocialSignInButton(
                      text: 'Tiếp tục với Facebook',
                      iconAsset: 'assets/images/facebook_logo.png',
                      onPressed: _handleFacebookSignIn,
                    ),
                    const SizedBox(height: 20),
                    // Divider with text "hoặc tiếp tục với email"
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white70)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'hoặc tiếp tục với email',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 20), // Adjusted space

                    if (!_isSignInMode) ...[
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Tên đầy đủ',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Địa chỉ Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    if (!_isSignInMode) ...[
                      const SizedBox(height: 16),
                      _buildConfirmPasswordField(),
                    ],
                    if (_isSignInMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: authController.isLoading ? null : _handleAuth,
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
                          : Text(
                              _isSignInMode ? 'Đăng nhập' : 'Tạo tài khoản',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
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
                    const SizedBox(height: 40),
                    Row(
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
                              authController.clearErrorMessage();
                            });
                          },
                          child: Text(
                            _isSignInMode ? 'Đăng ký' : 'Đăng nhập',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
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

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Mật khẩu',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
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

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Xác nhận mật khẩu',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
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

  // New helper widget for social sign-in buttons
  Widget _buildSocialSignInButton({
    required String text,
    required String iconAsset,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0, // No shadow for a flatter look
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconAsset, height: 24), // Display the icon
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
