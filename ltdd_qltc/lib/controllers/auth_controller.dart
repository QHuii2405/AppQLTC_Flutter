// auth_controller.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ltdd_qltc/services/database_helper.dart';
import 'package:ltdd_qltc/models/user.dart';

class AuthController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  AuthController(this._dbHelper);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<User?> signIn(String email, String password) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      User? user = await _dbHelper.getUserByEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return user;
      } else {
        setErrorMessage('Email hoặc mật khẩu không hợp lệ.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi đăng nhập: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signUp(String name, String email, String password) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        setErrorMessage('Email đã được đăng ký.');
        return null;
      }

      final newUser = User(
        email: email,
        password: password,
        name: name,
        createdAt: DateTime.now().toIso8601String(),
      );
      final userId = await _dbHelper.insertUser(newUser);

      if (userId > 0) {
        // Load default accounts and categories for the new user
        await _dbHelper.createDefaultAccountAndCategories(userId);

        _currentUser = newUser.copyWith(id: userId);
        notifyListeners();
        return _currentUser;
      } else {
        setErrorMessage('Không thể tạo tài khoản.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi đăng ký: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateUserProfile(User user) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      bool success = await _dbHelper.updateUser(user);
      if (success) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể cập nhật hồ sơ.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật hồ sơ: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    _setLoading(true);
    clearErrorMessage();

    if (newPassword != confirmNewPassword) {
      setErrorMessage('Mật khẩu mới và xác nhận không khớp.');
      _setLoading(false);
      return false;
    }
    if (newPassword.length < 6) {
      setErrorMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');
      _setLoading(false);
      return false;
    }

    try {
      User? user = await _dbHelper.getUserById(userId);
      if (user == null) {
        setErrorMessage('Người dùng không tồn tại.');
        return false;
      }

      if (user.password != oldPassword) {
        setErrorMessage('Mật khẩu cũ không đúng.');
        return false;
      }

      final updatedUser = user.copyWith(password: newPassword);
      bool success = await _dbHelper.updateUser(updatedUser);

      if (success) {
        if (_currentUser?.id == userId) {
          _currentUser = updatedUser;
          notifyListeners();
        }
        return true;
      } else {
        setErrorMessage('Không thể đổi mật khẩu.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi đổi mật khẩu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Send reset token to email
  Future<bool> sendResetToken(String email) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        setErrorMessage('Không tìm thấy tài khoản với email này.');
        return false;
      }

      // Generate a simple token (in a real app, this would be more secure and sent via email)
      final String resetToken =
          (Random().nextInt(900000) + 100000).toString(); // 6-digit number
      final int expiresAt =
          DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;

      bool success = await _dbHelper.updateUserResetToken(
        email,
        resetToken,
        expiresAt,
      );

      if (success) {
        // In a real app, you would send this token to the user's email.
        // For this example, we'll just print it to the console for testing.
        print('Mã đặt lại mật khẩu cho $email: $resetToken');
        setErrorMessage('Mã đặt lại đã được gửi đến email của bạn. Vui lòng kiểm tra console để lấy mã.');
        return true;
      } else {
        setErrorMessage('Không thể gửi mã đặt lại mật khẩu.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi gửi mã đặt lại: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Reset password with token
  Future<bool> resetPasswordWithToken(
      String email, String token, String newPassword, String confirmPassword) async {
    _setLoading(true);
    clearErrorMessage();

    if (newPassword != confirmPassword) {
      setErrorMessage('Mật khẩu mới và xác nhận không khớp.');
      _setLoading(false);
      return false;
    }
    if (newPassword.length < 6) {
      setErrorMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');
      _setLoading(false);
      return false;
    }

    try {
      bool success = await _dbHelper.resetPassword(email, newPassword, token);
      if (success) {
        setErrorMessage('Đặt lại mật khẩu thành công!');
        return true;
      } else {
        setErrorMessage('Mã đặt lại không hợp lệ hoặc đã hết hạn.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi đặt lại mật khẩu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}