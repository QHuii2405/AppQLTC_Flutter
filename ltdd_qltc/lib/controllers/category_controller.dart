import 'package:flutter/material.dart';
import 'package:ltdd_qltc/services/database_helper.dart'; // Đã sửa đường dẫn import
import 'package:ltdd_qltc/models/category.dart';     // Đã sửa đường dẫn import
import 'package:intl/intl.dart'; // Import for date formatting

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
      // Sắp xếp danh mục theo tên hoặc loại nếu cần
      _categories.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      setErrorMessage('Lỗi khi tải danh mục: $e');
      print('CategoryController - Lỗi tải danh mục: $e'); // Log lỗi chi tiết hơn
    } finally {
      _setLoading(false);
    }
  }

  // Thêm một danh mục mới
  Future<bool> addCategory(Category category) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      // Kiểm tra xem danh mục đã tồn tại chưa (theo tên và loại)
      bool categoryExists = _categories.any((c) =>
          c.name.toLowerCase() == category.name.toLowerCase() &&
          c.type == category.type);
      if (categoryExists) {
        setErrorMessage('Danh mục "${category.name}" đã tồn tại.');
        return false;
      }

      final newId = await _dbHelper.insertCategory(category);
      if (newId > 0) {
        // Cập nhật danh sách cục bộ và notify
        final newCategoryWithId = category.copyWith(id: newId);
        _categories.add(newCategoryWithId);
        _categories.sort((a, b) => a.name.compareTo(b.name)); // Sắp xếp lại
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể thêm danh mục.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi thêm danh mục: $e');
      print('CategoryController - Lỗi thêm danh mục: $e'); // Log lỗi chi tiết hơn
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
      // Kiểm tra xem có danh mục nào khác có cùng tên và loại không
      bool duplicateExists = _categories.any((c) =>
          c.id != category.id &&
          c.name.toLowerCase() == category.name.toLowerCase() &&
          c.type == category.type);

      if (duplicateExists) {
        setErrorMessage('Danh mục "${category.name}" đã tồn tại.');
        return false;
      }

      int rowsAffected = await _dbHelper.updateCategory(category);
      if (rowsAffected > 0) {
        // Cập nhật danh mục trong danh sách cục bộ
        int index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
        }
        _categories.sort((a, b) => a.name.compareTo(b.name)); // Sắp xếp lại
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Không thể cập nhật danh mục.');
        return false;
      }
    } catch (e) {
      setErrorMessage('Lỗi khi cập nhật danh mục: $e');
      print('CategoryController - Lỗi cập nhật danh mục: $e'); // Log lỗi chi tiết hơn
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
      print('CategoryController - Lỗi xóa danh mục: $e'); // Log lỗi chi tiết hơn
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Lấy icon dựa trên tên danh mục (đã có trong HomeController, có thể trùng lặp hoặc dùng chung)
  // Tạm thời giữ lại nếu cần dùng độc lập trong CategoryController
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

// Mở rộng lớp Category để thêm phương thức copyWith
// Giúp tạo một bản sao của Category với các trường được thay đổi dễ dàng hơn
extension CategoryCopyWith on Category {
  Category copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    String? icon,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
