import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:flutter_application_1/models/account.dart';

class WalletController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  List<Account> _wallets = [];
  bool _isLoading = false;
  String? _errorMessage;

  WalletController(this._dbHelper);

  List<Account> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWallets(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wallets = await _dbHelper.getAccounts(userId);
    } catch (e) {
      _errorMessage = 'Lỗi khi tải ví: $e';
      print('Lỗi tải ví: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWallet(Account account) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int id = await _dbHelper.insertAccount(account);
      if (id > 0) {
        // Tải lại danh sách ví sau khi thêm thành công
        await loadWallets(account.userId);
        return true;
      } else {
        _errorMessage = 'Không thể thêm ví.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm ví: $e';
      print('Lỗi thêm ví: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWallet(Account account) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int rowsAffected = await _dbHelper.updateAccount(account);
      if (rowsAffected > 0) {
        await loadWallets(account.userId); // Tải lại danh sách ví
        return true;
      } else {
        _errorMessage = 'Không thể cập nhật ví.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật ví: $e';
      print('Lỗi cập nhật ví: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWallet(int walletId, int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int rowsAffected = await _dbHelper.deleteAccount(walletId);
      if (rowsAffected > 0) {
        await loadWallets(userId); // Tải lại danh sách ví
        return true;
      } else {
        _errorMessage = 'Không thể xóa ví.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa ví: $e';
      print('Lỗi xóa ví: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
