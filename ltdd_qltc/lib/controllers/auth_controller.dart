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
      if (await _dbHelper.getUserByEmail(email) != null) {
        setErrorMessage('Email đã tồn tại. Vui lòng sử dụng email khác.');
        return null;
      }

      final newUser = User(
        email: email,
        password: password,
        name: name,
        createdAt: DateTime.now().toIso8601String(),
      );

      int newId = await _dbHelper.insertUser(newUser);
      if (newId > 0) {
        final createdUser = newUser.copyWith(id: newId);
        _currentUser = createdUser;
        await _dbHelper.createDefaultAccountAndCategories(newId);
        notifyListeners();
        return createdUser;
      } else {
        setErrorMessage('Đăng ký thất bại. Vui lòng thử lại.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi đăng ký: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile(User updatedUser) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      bool success = await _dbHelper.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;
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

  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      User? user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        setErrorMessage('Email không tồn tại.');
        return null;
      }
      String token = await _dbHelper.generateAndSaveResetToken(user.id!);
      return token;
    } catch (e) {
      setErrorMessage('Lỗi khi gửi mã đặt lại: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(
    String email,
    String token,
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
      bool success = await _dbHelper.resetPassword(email, token, newPassword);
      if (success) {
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

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
