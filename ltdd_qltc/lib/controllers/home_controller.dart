import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/models/transaction.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/services/database_helper.dart';

class HomeController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  User? _currentUser;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  // Dữ liệu đã xử lý cho UI
  Map<int, double> _incomeByMonth = {};
  Map<int, double> _expenseByMonth = {};
  Map<String, List<Transaction>> _groupedTransactions = {};

  HomeController(this._dbHelper);

  // Getters để UI truy cập
  User? get currentUser => _currentUser;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  Map<int, double> get incomeByMonth => _incomeByMonth;
  Map<int, double> get expenseByMonth => _expenseByMonth;
  Map<String, List<Transaction>> get groupedTransactions =>
      _groupedTransactions;

  // Lấy icon dựa trên tên danh mục (ưu tiên icon từ DB)
  String getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'ăn uống':
        return '🍽️';
      case 'du lịch':
        return '✈️';
      case 'tiền lương':
        return '�';
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
        return '💸'; // Icon mặc định
    }
  }

  // Lấy tên ngày trong tuần/Hôm nay/Hôm qua
  String getDayName(String dateString) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      final today = DateTime.now();
      final yesterday =
          DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));
      final currentDay = DateTime(today.year, today.month, today.day);

      if (date.year == currentDay.year &&
          date.month == currentDay.month &&
          date.day == currentDay.day) {
        return 'Hôm nay';
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return 'Hôm qua';
      } else {
        // Sử dụng 'vi' locale để có tên thứ tiếng Việt
        return DateFormat('EEEE', 'vi').format(date);
      }
    } catch (e) {
      print('Lỗi định dạng ngày: $e');
      return dateString; // Trả về chuỗi gốc nếu có lỗi
    }
  }

  // Tải và xử lý dữ liệu cho HomeScreen
  Future<void> loadHomeData(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _dbHelper.getUserById(userId);
      await _dbHelper.insertInitialSampleData(userId);
      _transactions = await _dbHelper.getTransactions(userId);

      // Xử lý dữ liệu sau khi tải
      _processTransactionData();
    } catch (e) {
      print('Lỗi khi tải dữ liệu trang chủ: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Phương thức xử lý và nhóm dữ liệu
  void _processTransactionData() {
    // Sắp xếp giao dịch
    _transactions.sort(
      (a, b) => DateFormat('yyyy-MM-dd')
          .parse(b.transactionDate)
          .compareTo(DateFormat('yyyy-MM-dd').parse(a.transactionDate)),
    );

    // Reset dữ liệu đã tính toán
    _incomeByMonth = {for (var i = 1; i <= 12; i++) i: 0.0};
    _expenseByMonth = {for (var i = 1; i <= 12; i++) i: 0.0};
    _groupedTransactions = {};
    
    final currentYear = DateTime.now().year;

    for (var transaction in _transactions) {
      final transactionDate = DateTime.tryParse(transaction.transactionDate);
      if (transactionDate == null) continue;

      // 1. Nhóm giao dịch theo ngày cho danh sách
      final formattedDate = DateFormat('dd/MM/yyyy').format(transactionDate);
      if (!_groupedTransactions.containsKey(formattedDate)) {
        _groupedTransactions[formattedDate] = [];
      }
      _groupedTransactions[formattedDate]!.add(transaction);

      // 2. Tính tổng thu/chi theo tháng cho biểu đồ
      if (transactionDate.year == currentYear) {
        if (transaction.type == 'income') {
          _incomeByMonth.update(transactionDate.month, (value) => value + transaction.amount, ifAbsent: () => transaction.amount);
        } else {
          _expenseByMonth.update(transactionDate.month, (value) => value + transaction.amount, ifAbsent: () => transaction.amount);
        }
      }
    }
  }

  // Cập nhật thông tin người dùng
  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}