import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ltdd_qltc/services/database_helper.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'dart:core'; // Đảm bảo DateTime được nhận diện

class AuthController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser; // Thêm biến này để lưu trữ người dùng hiện tại

  AuthController(this._dbHelper);

  // Getters để truy cập trạng thái từ bên ngoài
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  // Phương thức nội bộ để cập nhật trạng thái loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Phương thức để đặt thông báo lỗi
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Phương thức để xóa thông báo lỗi
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Phương thức xử lý đăng nhập
  Future<User?> signIn(String email, String password) async {
    _setLoading(true);
    clearErrorMessage(); // Xóa lỗi cũ trước khi thử lại
    try {
      User? user = await _dbHelper.getUserByEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user; // Lưu người dùng đã đăng nhập
        // await _dbHelper.insertLoginHistory(user.id!); // Ghi lại lịch sử đăng nhập
        notifyListeners(); // Thông báo lắng nghe về sự thay đổi của _currentUser
        return user;
      } else {
        setErrorMessage('Email hoặc mật khẩu không hợp lệ.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi đăng nhập: $e');
      print('Lỗi đăng nhập: $e'); // In lỗi ra console để debug
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý đăng ký
  Future<User?> signUp(String email, String password, String name) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      // Kiểm tra email đã tồn tại chưa
      if (await _dbHelper.getUserByEmail(email) != null) {
        setErrorMessage('Email đã tồn tại. Vui lòng sử dụng email khác.');
        return null;
      }

      final newUser = User(
        email: email,
        password: password, // Mật khẩu chưa được hash, cần hash trong DB
        name: name,
        createdAt: DateTime.now().toIso8601String(),
      );

      int newId = await _dbHelper.insertUser(newUser);
      if (newId > 0) {
        final createdUser = newUser.copyWith(id: newId);
        _currentUser = createdUser; // Lưu người dùng mới đăng ký
        notifyListeners(); // Thông báo lắng nghe về sự thay đổi của _currentUser
        // Tạo ví tiền mặc định cho người dùng mới
        await _dbHelper.createDefaultAccountAndCategories(newId);
        return createdUser;
      } else {
        setErrorMessage('Đăng ký thất bại. Vui lòng thử lại.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi đăng ký: $e');
      print('Lỗi đăng ký: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức cập nhật hồ sơ người dùng
  Future<bool> updateUserProfile(User updatedUser) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      bool success = await _dbHelper.updateUser(updatedUser);
      if (success) {
        _currentUser =
            updatedUser; // Cập nhật người dùng hiện tại trong controller
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể cập nhật hồ sơ.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật hồ sơ: $e');
      print('Lỗi cập nhật hồ sơ: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý quên mật khẩu (gửi mã đặt lại)
  Future<String?> sendResetCode(String email) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      User? user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        setErrorMessage('Email không tồn tại.');
        return null;
      }
      String token = (Random().nextInt(900000) + 100000)
          .toString(); // Mã 6 chữ số
      final expires = DateTime.now()
          .add(const Duration(minutes: 10))
          .millisecondsSinceEpoch; // Hết hạn sau 10 phút

      // Gọi phương thức trong dbHelper để lưu token
      await _dbHelper.updateUser(
        user.copyWith(resetToken: token, resetTokenExpires: expires),
      );

      return token; // Trả về token để hiển thị cho người dùng (trong thực tế sẽ gửi qua email)
    } catch (e) {
      setErrorMessage('Lỗi khi gửi mã đặt lại: $e');
      print('Lỗi gửi mã đặt lại: $e'); // In lỗi ra console để debug
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức MỚI: forgotPassword (để xử lý lời gọi bị lỗi)
  // Thực tế nó sẽ gọi sendResetCode
  Future<String?> forgotPassword(String email) async {
    return await sendResetCode(email);
  }

  // Phương thức xử lý đặt lại mật khẩu
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
      print('Lỗi đặt lại mật khẩu: $e'); // In lỗi ra console
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức MỚI: changePassword
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

      // Giả sử mật khẩu được lưu dưới dạng plain text hoặc đã được hash
      // Trong thực tế, bạn sẽ so sánh mật khẩu cũ đã được hash
      if (user.password != oldPassword) {
        setErrorMessage('Mật khẩu cũ không đúng.');
        return false;
      }

      // Cập nhật mật khẩu mới trong database
      final updatedUser = user.copyWith(password: newPassword);
      bool success = await _dbHelper.updateUser(updatedUser);

      if (success) {
        // Cập nhật _currentUser trong AuthController nếu người dùng hiện tại là người đang đổi mật khẩu
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
      print('Lỗi đổi mật khẩu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức đăng xuất
  void signOut() {
    _currentUser = null; // Xóa người dùng hiện tại
    notifyListeners(); // Thông báo cho các lắng nghe
  }
}
