import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  // Controller này có thể đơn giản vì màn hình cài đặt chủ yếu là điều hướng
  // và hiển thị các tùy chọn tĩnh.
  // Tuy nhiên, nếu có các cài đặt động (ví dụ: bật/tắt thông báo),
  // logic đó sẽ nằm ở đây.

  SettingsController();

  // Ví dụ: có thể có một phương thức để lấy trạng thái thông báo từ Model/Service
  // bool _isNotificationsEnabled = false;
  // bool get isNotificationsEnabled => _isNotificationsEnabled;
  // Future<void> toggleNotifications(bool value) async {
  //   // Cập nhật Model/Service
  //   _isNotificationsEnabled = value;
  //   notifyListeners();
  // }
}
