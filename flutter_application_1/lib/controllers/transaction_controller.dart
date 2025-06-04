import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:flutter_application_1/models/transaction.dart';
import 'package:flutter_application_1/models/account.dart'; // Cần để cập nhật số dư ví
import 'package:flutter_application_1/models/category.dart'; // Cần để lấy thông tin danh mục

class TransactionController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  bool _isLoading = false;
  String? _errorMessage;

  TransactionController(this._dbHelper);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> addTransaction(Transaction transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Logic thêm giao dịch vào database và cập nhật số dư tài khoản
      await _dbHelper.insertTransaction(transaction);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm giao dịch: $e';
      print('Lỗi thêm giao dịch: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Logic cập nhật giao dịch và điều chỉnh số dư tài khoản
      await _dbHelper.updateTransaction(oldTransaction, newTransaction);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật giao dịch: $e';
      print('Lỗi cập nhật giao dịch: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransaction(int transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Logic xóa giao dịch và hoàn tác số dư tài khoản
      await _dbHelper.deleteTransaction(transactionId);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa giao dịch: $e';
      print('Lỗi xóa giao dịch: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bạn có thể thêm các phương thức khác như getTransactionsByDateRange, getTransactionsByCategory, v.v.
}
