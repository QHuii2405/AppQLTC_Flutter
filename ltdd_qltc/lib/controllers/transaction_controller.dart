import 'package:flutter/material.dart';
import 'package:ltdd_qltc/services/database_helper.dart';
import 'package:ltdd_qltc/models/transaction.dart';

class TransactionController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  TransactionController(this._dbHelper);

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  // Tải tất cả giao dịch cho một người dùng cụ thể
  Future<void> loadTransactions(int userId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      _transactions = await _dbHelper.getTransactions(userId);
      // Sắp xếp lại nếu cần, ví dụ theo ngày mới nhất
      _transactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );
    } catch (e) {
      setErrorMessage('Lỗi khi tải giao dịch: $e');
      print('Lỗi tải giao dịch: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Thêm một giao dịch mới
  Future<bool> addTransaction(Transaction transaction) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final newId = await _dbHelper.insertTransaction(transaction);
      if (newId > 0) {
        // Tải lại danh sách hoặc thêm trực tiếp vào _transactions (tốt hơn nên tải lại để đảm bảo đồng bộ)
        await loadTransactions(transaction.userId);
        return true;
      } else {
        setErrorMessage('Không thể thêm giao dịch.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi thêm giao dịch: $e');
      print('Lỗi thêm giao dịch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật một giao dịch hiện có
  // Chỉ nhận một đối tượng Transaction đã được cập nhật
  Future<bool> updateTransaction(Transaction transaction) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int rowsAffected = await _dbHelper.updateTransaction(transaction);
      if (rowsAffected > 0) {
        // Cập nhật giao dịch trong danh sách cục bộ hoặc tải lại
        await loadTransactions(transaction.userId);
        return true;
      } else {
        setErrorMessage('Không thể cập nhật giao dịch.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật giao dịch: $e');
      print('Lỗi cập nhật giao dịch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa một giao dịch
  Future<bool> deleteTransaction(int transactionId, int userId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int rowsAffected = await _dbHelper.deleteTransaction(transactionId);
      if (rowsAffected > 0) {
        // Xóa khỏi danh sách cục bộ hoặc tải lại
        await loadTransactions(userId);
        return true;
      } else {
        setErrorMessage('Không thể xóa giao dịch.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi xóa giao dịch: $e');
      print('Lỗi xóa giao dịch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
