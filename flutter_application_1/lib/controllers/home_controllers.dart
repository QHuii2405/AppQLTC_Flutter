import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:intl/intl.dart';

class HomeController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  User? _currentUser;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  HomeController(this._dbHelper);

  User? get currentUser => _currentUser;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Lấy icon dựa trên tên danh mục
  String getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'ăn uống':
        return '🍽️';
      case 'du lịch':
        return '✈️';
      case 'tiền lương':
        return '💰';
      case 'chữa bệnh':
        return '🏥';
      case 'di chuyển':
        return '🚗';
      case 'hóa đơn':
        return '🧾';
      case 'mua sắm':
        return '🛍️';
      case 'thưởng':
        return '🎁';
      case 'thu nhập khác':
        return '📈';
      default:
        return '💸';
    }
  }

  // Lấy tên ngày trong tuần/Hôm nay/Hôm qua
  String getDayName(String dateString) {
    try {
      final date = DateFormat(
        'yyyy-MM-dd',
      ).parse(dateString); // Parse từ định dạng DB
      final today = DateTime.now();
      final yesterday = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 1));
      final currentDay = DateTime(today.year, today.month, today.day);

      if (date.day == currentDay.day &&
          date.month == currentDay.month &&
          date.year == currentDay.year) {
        return 'Hôm nay';
      } else if (date.day == yesterday.day &&
          date.month == yesterday.month &&
          date.year == yesterday.year) {
        return 'Hôm qua';
      } else {
        final weekdays = [
          'Chủ nhật',
          'Thứ hai',
          'Thứ ba',
          'Thứ tư',
          'Thứ năm',
          'Thứ sáu',
          'Thứ bảy',
        ];
        return weekdays[date.weekday % 7];
      }
    } catch (e) {
      print('Lỗi định dạng ngày: $e');
      return dateString; // Trả về chuỗi gốc nếu có lỗi
    }
  }

  // Tải dữ liệu cho HomeScreen
  Future<void> loadHomeData(int userId) async {
    _isLoading = true;
    notifyListeners(); // Thông báo cho View rằng đang tải

    try {
      // Lấy thông tin người dùng
      _currentUser = await _dbHelper.getUserById(userId);

      // Chèn dữ liệu mẫu nếu chưa có
      await _dbHelper.insertInitialSampleData(userId);

      // Lấy giao dịch
      _transactions = await _dbHelper.getTransactions(userId);

      // Sắp xếp giao dịch theo ngày giảm dần
      _transactions.sort(
        (a, b) => DateFormat('yyyy-MM-dd')
            .parse(b.transactionDate)
            .compareTo(DateFormat('yyyy-MM-dd').parse(a.transactionDate)),
      );
    } catch (e) {
      print('Lỗi khi tải dữ liệu trang chủ: $e');
      // Có thể thêm logic xử lý lỗi hoặc thông báo cho người dùng
    } finally {
      _isLoading = false;
      notifyListeners(); // Thông báo cho View rằng đã tải xong
    }
  }

  // Cập nhật thông tin người dùng (ví dụ từ ProfileScreen)
  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
