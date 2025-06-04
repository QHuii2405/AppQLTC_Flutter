import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/category_controller.dart';
import 'package:flutter_application_1/models/category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _loggedInUserId; // Để lưu trữ userId

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy userId từ arguments (được truyền từ SettingsScreen)
    if (_loggedInUserId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) {
        _loggedInUserId = args;
        // Tải danh mục khi màn hình được khởi tạo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<CategoryController>(context, listen: false).loadCategories(_loggedInUserId!);
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý Thể loại',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5CBDD9),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Chi tiêu'),
            Tab(text: 'Thu nhập'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5CBDD9),
              Color(0xFF4BAFCC),
            ],
          ),
        ),
        child: Consumer<CategoryController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            final expenseCategories = controller.categories.where((c) => c.type == 'expense').toList();
            final incomeCategories = controller.categories.where((c) => c.type == 'income').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryGrid(expenseCategories, 'expense', controller),
                _buildCategoryGrid(incomeCategories, 'income', controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories, String type, CategoryController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8, // Tỷ lệ khung hình để icon và text hiển thị tốt
      ),
      itemCount: categories.length + 1, // +1 cho nút thêm mới
      itemBuilder: (context, index) {
        if (index == categories.length) {
          // Nút thêm mới
          return _buildAddCategoryButton(type, controller);
        } else {
          // Hiển thị danh mục hiện có
          final category = categories[index];
          return _buildCategoryItem(category, controller);
        }
      },
    );
  }

  Widget _buildCategoryItem(Category category, CategoryController controller) {
    return GestureDetector(
      onLongPress: () => _confirmDeleteCategory(category, controller), // Giữ để xóa
      onTap: () {
        _showSnackBar('Chỉnh sửa danh mục: ${category.name}');
        // Có thể mở dialog chỉnh sửa danh mục tại đây
        _showAddEditCategoryDialog(context, controller, category: category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.icon ?? '❓', // Hiển thị icon
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton(String type, CategoryController controller) {
    return GestureDetector(
      onTap: () => _showAddEditCategoryDialog(context, controller, type: type),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), style: BorderStyle.dashed),
        ),
        child: const Center(
          child: Icon(
            Icons.add_circle_outline,
            color: Colors.white70,
            size: 50,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteCategory(Category category, CategoryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Thể loại'),
        content: Text('Bạn có chắc chắn muốn xóa thể loại "${category.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog
              bool success = await controller.deleteCategory(category.id!);
              if (success) {
                _showSnackBar('Đã xóa thể loại: ${category.name}');
              } else {
                _showSnackBar(controller.errorMessage ?? 'Không thể xóa thể loại.');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAddEditCategoryDialog(BuildContext context, CategoryController controller, {String? type, Category? category}) {
    final TextEditingController nameController = TextEditingController(text: category?.name);
    final TextEditingController iconController = TextEditingController(text: category?.icon);
    String selectedType = type ?? category?.type ?? 'expense'; // Mặc định là 'expense'

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(category == null ? 'Thêm Thể loại mới' : 'Chỉnh sửa Thể loại'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên thể loại',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: iconController,
                    decoration: const InputDecoration(
                      labelText: 'Biểu tượng (Emoji)',
                      hintText: 'Ví dụ: �️, 🛍️, 💰',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Loại:'),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedType,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedType = newValue;
                            });
                          }
                        },
                        items: const <String>['expense', 'income']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value == 'expense' ? 'Chi tiêu' : 'Thu nhập'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || iconController.text.isEmpty) {
                    _showSnackBar('Vui lòng điền đầy đủ thông tin.');
                    return;
                  }

                  if (category == null) {
                    // Thêm mới
                    final newCategory = Category(
                      userId: _loggedInUserId!, // Đảm bảo userId có sẵn
                      name: nameController.text,
                      type: selectedType,
                      icon: iconController.text,
                      createdAt: DateTime.now().toIso8601String(),
                    );
                    bool success = await controller.addCategory(newCategory);
                    if (success) {
                      _showSnackBar('Đã thêm thể loại: ${newCategory.name}');
                      Navigator.pop(context);
                    } else {
                      _showSnackBar(controller.errorMessage ?? 'Không thể thêm thể loại.');
                    }
                  } else {
                    // Chỉnh sửa
                    category.name = nameController.text;
                    category.icon = iconController.text;
                    category.type = selectedType;
                    bool success = await controller.updateCategory(category);
                    if (success) {
                      _showSnackBar('Đã cập nhật thể loại: ${category.name}');
                      Navigator.pop(context);
                    } else {
                      _showSnackBar(controller.errorMessage ?? 'Không thể cập nhật thể loại.');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CBDD9),
                  foregroundColor: Colors.white,
                ),
                child: Text(category == null ? 'Thêm' : 'Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
�