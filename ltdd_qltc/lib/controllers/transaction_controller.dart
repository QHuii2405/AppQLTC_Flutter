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

  Future<void> loadTransactions(int userId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      _transactions = await _dbHelper.getTransactions(userId);
      _transactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );
    } catch (e) {
      setErrorMessage('Lỗi khi tải giao dịch: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final newId = await _dbHelper.insertTransaction(transaction);
      if (newId > 0) {
        await loadTransactions(transaction.userId);
        return true;
      } else {
        setErrorMessage('Không thể thêm giao dịch.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi thêm giao dịch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int rowsAffected = await _dbHelper.updateTransaction(transaction);
      if (rowsAffected > 0) {
        await loadTransactions(transaction.userId);
        return true;
      } else {
        setErrorMessage('Không thể cập nhật giao dịch.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật giao dịch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(int transactionId, int userId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int rowsAffected = await _dbHelper.deleteTransaction(transactionId);
      if (rowsAffected > 0) {
        await loadTransactions(userId);
        return true;
      } else {
        setErrorMessage('Không thể xóa giao dịch.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi xóa giao dịch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
