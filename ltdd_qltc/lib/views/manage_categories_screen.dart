import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/category.dart';
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:intl/intl.dart'; // For DateTime formatting if needed

class ManageCategoriesScreen extends StatefulWidget {
  final User user;
  const ManageCategoriesScreen({super.key, required this.user});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categoryIcons = [
    '🍽️', '✈️', '💰', '🏥', '🚗', '🧾', '🛍️', '🎁', '📈', '🏠', '💻', '📚', '🎁', '🎉',
    '💇', '💡', '💧', '📞', '⚽', '🎥', '🛒', '👕', '💊', '🚌', '🚆', '🚲', '⛽',
    '🧑‍💻', '🎮', '🎤', '🏞️', '🎓', '👶', '🐾', '⚙️', '✨', '🌱', '💍', '💼', '📊',
    '🛡️', '🔔', '🗑️', '🔧', '🔄', '➕', '➖', '✅', '❌', '➡️', '⬅️', '⬆️', '⬇️',
    '⭐', '❤️', '🧡', '💛', '💚', '💙', '💜', '🤎', '🖤', '🤍', '💖', '💡', '🎁'
  ]; // Danh sách các icon gợi ý

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Tải danh mục khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user.id != null) {
        Provider.of<CategoryController>(context, listen: false)
            .loadCategories(widget.user.id!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hàm hiển thị dialog thêm/sửa danh mục
  void _showCategoryDialog({Category? category}) {
    final TextEditingController nameController =
        TextEditingController(text: category?.name);
    String selectedIcon = category?.icon ?? _categoryIcons.first; // Icon mặc định hoặc đã chọn
    String categoryType = category?.type ?? 'expense'; // Loại mặc định

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF4BAFCC), // Màu nền dialog
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              title: Text(
                category == null ? 'Tạo danh mục mới' : 'Chỉnh sửa danh mục',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tên danh mục',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.label_outline, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Chọn Icon
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Icon(Icons.emoji_emotions_outlined, color: Colors.white70),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedIcon,
                                dropdownColor: const Color(0xFF4BAFCC),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setStateInDialog(() {
                                      selectedIcon = newValue;
                                    });
                                  }
                                },
                                items: _categoryIcons.map<DropdownMenuItem<String>>((String icon) {
                                  return DropdownMenuItem<String>(
                                    value: icon,
                                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Chọn loại danh mục (Thu/Chi)
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Chi tiêu', style: TextStyle(color: Colors.white)),
                            value: 'expense',
                            groupValue: categoryType,
                            onChanged: (String? value) {
                              setStateInDialog(() {
                                categoryType = value!;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Thu nhập', style: TextStyle(color: Colors.white)),
                            value: 'income',
                            groupValue: categoryType,
                            onChanged: (String? value) {
                              setStateInDialog(() {
                                categoryType = value!;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final categoryName = nameController.text.trim();
                    if (categoryName.isEmpty) {
                      _showSnackBar('Tên danh mục không được để trống.');
                      return;
                    }

                    final controller =
                        Provider.of<CategoryController>(context, listen: false);
                    bool success;
                    if (category == null) {
                      // Thêm mới
                      final newCategory = Category(
                        userId: widget.user.id!,
                        name: categoryName,
                        type: categoryType,
                        icon: selectedIcon,
                        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                      );
                      success = await controller.addCategory(newCategory);
                    } else {
                      // Cập nhật
                      final updatedCategory = category.copyWith(
                        name: categoryName,
                        type: categoryType,
                        icon: selectedIcon,
                      );
                      success = await controller.updateCategory(updatedCategory);
                    }

                    if (success) {
                      Navigator.pop(context); // Đóng dialog
                      _showSnackBar(category == null
                          ? 'Thêm danh mục thành công!'
                          : 'Cập nhật danh mục thành công!');
                    } else {
                      _showSnackBar(controller.errorMessage ?? 'Đã xảy ra lỗi.');
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
        );
      },
    );
  }

  // Hàm hiển thị dialog xác nhận xóa
  void _showDeleteConfirmationDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4BAFCC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Bạn có chắc chắn muốn xóa danh mục "${category.name}" không? Thao tác này không thể hoàn tác.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final controller =
                    Provider.of<CategoryController>(context, listen: false);
                bool success = await controller.deleteCategory(category.id!);
                if (success) {
                  Navigator.pop(context); // Đóng dialog
                  _showSnackBar('Đã xóa danh mục "${category.name}".');
                } else {
                  _showSnackBar(
                      controller.errorMessage ?? 'Không thể xóa danh mục.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý Danh mục',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5CBDD9),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Màu chữ của tab được chọn
          unselectedLabelColor: Colors.white.withOpacity(0.7), // Màu chữ của tab không được chọn
          indicatorColor: Colors.white, // Màu của thanh chỉ báo dưới tab
          indicatorSize: TabBarIndicatorSize.tab, // Chiều rộng của thanh chỉ báo
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
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
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

            final expenseCategories = controller.categories
                .where((cat) => cat.type == 'expense')
                .toList();
            final incomeCategories = controller.categories
                .where((cat) => cat.type == 'income')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryGrid(expenseCategories, controller), // Grid cho Chi tiêu
                _buildCategoryGrid(incomeCategories, controller), // Grid cho Thu nhập
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(), // Nút thêm danh mục mới
        backgroundColor: const Color(0xFF2196F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Tạo hình tròn hoặc bo tròn mạnh
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Widget để xây dựng Grid danh mục
  Widget _buildCategoryGrid(List<Category> categories, CategoryController controller) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Chưa có danh mục nào. Nhấn "+" để thêm!',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 cột
        crossAxisSpacing: 10, // Khoảng cách ngang
        mainAxisSpacing: 10, // Khoảng cách dọc
        childAspectRatio: 0.9, // Tỷ lệ khung hình của mỗi item
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onLongPress: () {
            // Hiển thị menu chỉnh sửa/xóa khi nhấn giữ
            _showCategoryOptions(context, category);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15), // Bo tròn góc
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.icon ?? controller.getCategoryIcon(category.name), // Hiển thị icon
                  style: const TextStyle(fontSize: 36),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hàm hiển thị tùy chọn chỉnh sửa/xóa danh mục
  void _showCategoryOptions(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Nền trong suốt để thấy bo tròn
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF5CBDD9)),
                title: const Text('Chỉnh sửa danh mục'),
                onTap: () {
                  Navigator.pop(context); // Đóng bottom sheet
                  _showCategoryDialog(category: category); // Mở dialog chỉnh sửa
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Xóa danh mục', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context); // Đóng bottom sheet
                  _showDeleteConfirmationDialog(category); // Mở dialog xác nhận xóa
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
