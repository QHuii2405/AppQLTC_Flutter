import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:flutter_application_1/models/user.dart';
import 'dart:core'; // Đảm bảo DateTime được nhận diện

class AuthController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

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
        _currentUser = user;
        // TODO: Thêm logic lưu trạng thái đăng nhập (ví dụ: SharedPreferences)
        return user;
      } else {
        setErrorMessage('Email hoặc mật khẩu không hợp lệ.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi đăng nhập: $e');
      print('Lỗi đăng nhập: $e'); // In lỗi ra console để debug
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý đăng ký tài khoản mới
  Future<User?> signUp(String name, String email, String password) async {
    _setLoading(true);
    clearErrorMessage(); // Xóa lỗi cũ trước khi thử lại
    try {
      bool emailExists = await _dbHelper.checkEmailExists(email);
      if (emailExists) {
        setErrorMessage('Email đã tồn tại.');
        return null;
      }

      User newUser = User(
        name: name,
        email: email,
        password: password, // Trong thực tế: HASH mật khẩu này!
        createdAt: DateTime.now().toIso8601String(),
        profileImageUrl: null, // Mặc định là null khi đăng ký
        dob: null, // Mặc định là null khi đăng ký
        description: null, // Mặc định là null khi đăng ký
      );

      int id = await _dbHelper.insertUser(newUser);
      if (id > 0) {
        newUser.id = id; // Gán ID đã tạo từ database
        _currentUser = newUser;
        // Chèn dữ liệu mẫu ban đầu cho người dùng mới
        await _dbHelper.insertInitialSampleData(newUser.id!);
        return newUser; // Trả về User đã đăng ký thành công
      } else {
        setErrorMessage('Tạo tài khoản thất bại.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi tạo tài khoản: $e');
      print('Lỗi tạo tài khoản: $e'); // In lỗi ra console để debug
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý quên mật khẩu (tạo mã đặt lại)
  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    clearErrorMessage(); // Xóa lỗi cũ trước khi thử lại
    try {
      String? token = await _dbHelper.createResetToken(email);
      if (token != null) {
        // Trong ứng dụng thực tế, bạn sẽ gửi token này qua email/SMS
        print('Mã đặt lại cho $email: $token'); // Chỉ để debug trong console
        return token;
      } else {
        setErrorMessage('Không tìm thấy địa chỉ email.');
        return null;
      }
    } catch (e) {
      setErrorMessage('Lỗi gửi mã đặt lại: $e');
      print('Lỗi gửi mã đặt lại: $e'); // In lỗi ra console để debug
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý đặt lại mật khẩu
  Future<bool> resetPassword(
    String email,
    String token,
    String newPassword,
    String confirmNewPassword, // Đã thêm tham số này để khớp với SigninScreen
  ) async {
    _setLoading(true);
    clearErrorMessage(); // Xóa lỗi cũ trước khi thử lại
    if (newPassword != confirmNewPassword) {
      // So sánh mật khẩu mới và xác nhận
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
      print('Lỗi đặt lại mật khẩu: $e'); // In lỗi ra console để debug
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức xử lý đăng xuất
  void signOut() {
    _currentUser = null;
    // TODO: Xóa trạng thái đăng nhập đã lưu (ví dụ: SharedPreferences)
    notifyListeners();
  }
}
