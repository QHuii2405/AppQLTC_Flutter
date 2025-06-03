import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/database_helper.dart';

class ProfileController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  User? _currentUser;
  bool _isLoading = false;

  ProfileController(this._dbHelper);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Cập nhật người dùng hiện tại
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Lấy người dùng từ database (nếu cần)
  Future<void> fetchUser(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _dbHelper.getUserById(userId);
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lưu thay đổi thông tin người dùng vào database
  Future<bool> saveProfileChanges({
    required int userId,
    required String newName,
    String? oldPassword,
    String? newPassword,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      User? userToUpdate = await _dbHelper.getUserById(userId);
      if (userToUpdate == null) {
        print('Không tìm thấy người dùng với ID: $userId');
        return false;
      }

      // Cập nhật tên
      userToUpdate = userToUpdate.copyWith(name: newName);

      // Cập nhật ảnh đại diện
      userToUpdate = userToUpdate.copyWith(profileImageUrl: profileImageUrl);

      // Xử lý thay đổi mật khẩu
      if (oldPassword != null &&
          newPassword != null &&
          newPassword.isNotEmpty) {
        // Kiểm tra mật khẩu cũ (trong thực tế, mật khẩu trong DB phải được HASH)
        // Ở đây, chúng ta đang so sánh trực tiếp vì mật khẩu trong DB chưa được hash.
        // Bạn cần điều chỉnh logic này nếu đã hash mật khẩu.
        User? verifiedUser = await _dbHelper.getUserByEmailAndPassword(
          userToUpdate.email,
          oldPassword,
        );
        if (verifiedUser == null) {
          print('Mật khẩu cũ không đúng.');
          return false; // Mật khẩu cũ không đúng
        }
        userToUpdate = userToUpdate.copyWith(
          password: newPassword,
        ); // Trong thực tế: HASH mật khẩu mới trước khi lưu!
      }

      int rowsAffected = await _dbHelper.updateUser(userToUpdate);
      if (rowsAffected > 0) {
        _currentUser =
            userToUpdate; // Cập nhật lại người dùng hiện tại trong controller
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi lưu thay đổi hồ sơ: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
