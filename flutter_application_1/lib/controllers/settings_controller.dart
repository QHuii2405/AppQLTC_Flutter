import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart';

class SettingsController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;

  SettingsController(this._dbHelper);

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
    // Có thể lưu trạng thái này vào database thông qua _dbHelper
  }

  // Thêm các phương thức khác liên quan đến cài đặt ở đây
}
