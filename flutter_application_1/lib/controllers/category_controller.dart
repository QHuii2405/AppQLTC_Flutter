import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:flutter_application_1/models/category.dart';

class CategoryController extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  CategoryController(this._dbHelper);

  List<Category> get categories => _categories;
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

  // Tải tất cả danh mục cho một người dùng cụ thể
  Future<void> loadCategories(int userId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      _categories = await _dbHelper.getCategories(userId);
    } catch (e) {
      setErrorMessage('Lỗi khi tải danh mục: $e');
      print('Lỗi tải danh mục: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Thêm một danh mục mới
  Future<bool> addCategory(Category category) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int id = await _dbHelper.insertCategory(category);
      if (id > 0) {
        category.id = id;
        _categories.add(category);
        notifyListeners(); // Thông báo lắng nghe để cập nhật UI
        return true;
      } else {
        setErrorMessage('Không thể thêm danh mục.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi thêm danh mục: $e');
      print('Lỗi thêm danh mục: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật một danh mục hiện có
  Future<bool> updateCategory(Category category) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int rowsAffected = await _dbHelper.updateCategory(category);
      if (rowsAffected > 0) {
        // Cập nhật danh mục trong danh sách cục bộ
        int index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
        }
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể cập nhật danh mục.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật danh mục: $e');
      print('Lỗi cập nhật danh mục: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa một danh mục
  Future<bool> deleteCategory(int categoryId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      int rowsAffected = await _dbHelper.deleteCategory(categoryId);
      if (rowsAffected > 0) {
        _categories.removeWhere((c) => c.id == categoryId);
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể xóa danh mục.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi xóa danh mục: $e');
      print('Lỗi xóa danh mục: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
