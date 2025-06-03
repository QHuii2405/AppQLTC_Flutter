import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart'; // Đảm bảo đường dẫn chính xác
import 'package:flutter_application_1/models/user.dart'; // Import User model

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

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
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.only(top: 40, bottom: 60),
                  child: Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Form Fields
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                ),
                SizedBox(height: 20),
                _buildPasswordField(),

                // Forgot Password
                Container(
                  margin: EdgeInsets.only(top: 15),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      _showForgotPassword();
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // Login Button
                _buildLoginButton(),

                // Divider
                Container(
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'or',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      color: Color(0xFF1877F2),
                      icon: Icons.facebook,
                      onTap: () => _showFeatureNotAvailable(),
                    ),
                    SizedBox(width: 20),
                    _buildSocialButton(
                      color: Colors.red,
                      icon:
                          Icons.g_mobiledata, // Sử dụng g_mobiledata cho Google
                      onTap: () => _showFeatureNotAvailable(),
                    ),
                  ],
                ),

                Spacer(),

                // Sign Up Link
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Điều hướng đến màn hình đăng ký
                          // Giả định bạn có một route '/signup'
                          _showSnackBar('Tính năng đăng ký sẽ sớm ra mắt!');
                          // Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: Text(
                          'Sign up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return SizedBox(
      height: 55,
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      height: 55,
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
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
            borderSide: BorderSide(color: Colors.white30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ email và mật khẩu.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      // Sử dụng getUserByEmailAndPassword, trả về đối tượng User
      User? user = await dbHelper.getUserByEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        _showSnackBar('Đăng nhập thành công!');

        // Điều hướng đến home screen với đối tượng User
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/home', arguments: user);
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

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Quên mật khẩu'),
            content: Text(
              'Tính năng này chưa khả dụng. Vui lòng liên hệ hỗ trợ.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showFeatureNotAvailable() {
    _showSnackBar('Tính năng này chưa khả dụng');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
