import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart'; // Import User model
import 'package:flutter_application_1/services/database_helper.dart'; // Import DatabaseHelper

class ProfileController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  User? _currentUser; // Người dùng hiện tại

  ProfileController(this._dbHelper);

  User? get currentUser => _currentUser;

  // Phương thức để cập nhật người dùng hiện tại (khi đăng nhập hoặc ProfileScreen trả về)
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Phương thức để cập nhật thông tin hồ sơ của người dùng
  Future<bool> updateProfile({
    required int userId,
    required String name,
    String? profileImageUrl,
    String? dob,
    String? description,
  }) async {
    if (_currentUser == null || _currentUser!.id != userId) {
      print('Lỗi: Người dùng không khớp hoặc không có người dùng hiện tại.');
      return false;
    }

    // Cập nhật đối tượng User trong bộ nhớ
    _currentUser!.name = name;
    _currentUser!.profileImageUrl = profileImageUrl;
    _currentUser!.dob = dob;
    _currentUser!.description = description;

    try {
      // Cập nhật người dùng trong database
      int rowsAffected = await _dbHelper.updateUser(_currentUser!);
      if (rowsAffected > 0) {
        notifyListeners(); // Thông báo cho các listener rằng dữ liệu đã thay đổi
        return true;
      } else {
        print('Cập nhật hồ sơ thất bại trong database.');
        return false;
      }
    } catch (e) {
      print('Lỗi khi cập nhật hồ sơ: $e');
      return false;
    }
  }

  // Phương thức để lấy lại thông tin người dùng từ database (nếu cần)
  Future<void> fetchCurrentUser(int userId) async {
    try {
      User? fetchedUser = await _dbHelper.getUserById(userId);
      if (fetchedUser != null) {
        _currentUser = fetchedUser;
        notifyListeners();
      } else {
        print('Không tìm thấy người dùng với ID: $userId');
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
    }
  }
}
