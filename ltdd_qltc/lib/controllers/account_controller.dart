import 'package:flutter/material.dart';
import 'package:ltdd_qltc/services/database_helper.dart';
import 'package:ltdd_qltc/models/account.dart';

class AccountController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _errorMessage;

  AccountController(this._dbHelper);

  List<Account> get accounts => _accounts;
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

  // Tải tất cả tài khoản cho một người dùng cụ thể
  Future<void> loadAccounts(int userId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      _accounts = await _dbHelper.getAccounts(userId);
      _accounts.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      setErrorMessage('Lỗi khi tải tài khoản: $e');
      print('AccountController - Lỗi tải tài khoản: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Thêm một tài khoản mới
  Future<bool> addAccount(Account account) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      bool accountExists = _accounts.any(
        (a) =>
            a.name.toLowerCase() == account.name.toLowerCase() &&
            a.userId == account.userId,
      );
      if (accountExists) {
        setErrorMessage(
          'Tên ví "${account.name}" đã tồn tại. Vui lòng chọn tên khác.',
        ); // Đổi từ tài khoản sang ví
        return false;
      }

      final newId = await _dbHelper.insertAccount(account);
      if (newId > 0) {
        final newAccountWithId = account.copyWith(id: newId);
        _accounts.add(newAccountWithId);
        _accounts.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể thêm ví tiền.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi thêm ví tiền: $e');
      print('AccountController - Lỗi thêm ví tiền: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật một tài khoản hiện có
  Future<bool> updateAccount(Account account) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      // Lấy tài khoản cũ từ danh sách hiện có để so sánh tên
      final existingAccount = _accounts.firstWhere(
        (a) => a.id == account.id,
        orElse: () => throw Exception("Account not found for update"),
      );

      // Chỉ kiểm tra trùng lặp tên nếu tên tài khoản thực sự thay đổi
      if (existingAccount.name.toLowerCase() != account.name.toLowerCase()) {
        bool duplicateExists = _accounts.any(
          (a) =>
              a.id != account.id && // Đảm bảo không so sánh với chính nó
              a.name.toLowerCase() == account.name.toLowerCase() &&
              a.userId == account.userId,
        );

        if (duplicateExists) {
          setErrorMessage(
            'Tên ví "${account.name}" đã tồn tại. Vui lòng chọn tên khác.',
          );
          return false;
        }
      }

      int rowsAffected = await _dbHelper.updateAccount(account);
      if (rowsAffected > 0) {
        int index = _accounts.indexWhere((a) => a.id == account.id);
        if (index != -1) {
          _accounts[index] = account; // Cập nhật đối tượng trong danh sách
        }
        _accounts.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể cập nhật ví tiền.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật ví tiền: $e');
      print('AccountController - Lỗi cập nhật ví tiền: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa một tài khoản
  Future<bool> deleteAccount(int accountId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int rowsAffected = await _dbHelper.deleteAccount(accountId);
      if (rowsAffected > 0) {
        _accounts.removeWhere((a) => a.id == accountId);
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể xóa ví tiền.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi xóa ví tiền: $e');
      print('AccountController - Lỗi xóa ví tiền: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

// Extension AccountCopyWith vẫn giữ nguyên trong models/account.dart
// (Không thay đổi trong file này)
