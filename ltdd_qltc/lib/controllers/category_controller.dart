import 'package:flutter/material.dart';
import 'package:ltdd_qltc/services/database_helper.dart';
import 'package:ltdd_qltc/models/category.dart';

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

  Future<void> loadCategories(int userId) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      _categories = await _dbHelper.getCategories(userId);
      _categories.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      setErrorMessage('Lỗi khi tải danh mục: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addCategory(Category category) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      bool categoryExists = _categories.any(
        (c) =>
            c.name.toLowerCase() == category.name.toLowerCase() &&
            c.type == category.type &&
            c.userId == category.userId,
      );
      if (categoryExists) {
        setErrorMessage('Danh mục "${category.name}" đã tồn tại.');
        return false;
      }

      final newId = await _dbHelper.insertCategory(category);
      if (newId > 0) {
        final newCategoryWithId = category.copyWith(id: newId);
        _categories.add(newCategoryWithId);
        _categories.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể thêm danh mục.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi thêm danh mục: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory(Category category) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      bool duplicateExists = _categories.any(
        (c) =>
            c.id != category.id &&
            c.name.toLowerCase() == category.name.toLowerCase() &&
            c.type == category.type &&
            c.userId == category.userId,
      );

      if (duplicateExists) {
        setErrorMessage('Danh mục "${category.name}" đã tồn tại.');
        return false;
      }

      int rowsAffected = await _dbHelper.updateCategory(category);
      if (rowsAffected > 0) {
        int index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
        }
        _categories.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể cập nhật danh mục.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật danh mục: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

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
      return false;
    } finally {
      _setLoading(false);
    }
  }

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
}
