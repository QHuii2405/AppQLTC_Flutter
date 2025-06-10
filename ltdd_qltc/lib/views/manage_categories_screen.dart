import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/category.dart';
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:intl/intl.dart';

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
    '🍽️',
    '✈️',
    '💰',
    '🏥',
    '🚗',
    '🧾',
    '🛍️',
    '🎁',
    '📈',
    '🏠',
    '💻',
    '📚',
    '🎉',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user.id != null) {
        Provider.of<CategoryController>(
          context,
          listen: false,
        ).loadCategories(widget.user.id!);
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCategoryDialog({Category? category}) {
    final nameController = TextEditingController(text: category?.name);
    String selectedIcon = category?.icon ?? _categoryIcons.first;
    String categoryType =
        category?.type ?? (_tabController.index == 0 ? 'expense' : 'income');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(category == null ? 'Tạo danh mục' : 'Sửa danh mục'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên danh mục',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vui lòng nhập tên'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Biểu tượng',
                      ),
                      items: _categoryIcons
                          .map(
                            (icon) => DropdownMenuItem(
                              value: icon,
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateInDialog(() => selectedIcon = value);
                        }
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Chi'),
                            value: 'expense',
                            groupValue: categoryType,
                            onChanged: (value) =>
                                setStateInDialog(() => categoryType = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Thu'),
                            value: 'income',
                            groupValue: categoryType,
                            onChanged: (value) =>
                                setStateInDialog(() => categoryType = value!),
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
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final controller = Provider.of<CategoryController>(
                        context,
                        listen: false,
                      );
                      bool success;
                      if (category == null) {
                        final newCategory = Category(
                          userId: widget.user.id!,
                          name: nameController.text,
                          type: categoryType,
                          icon: selectedIcon,
                          createdAt: DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(DateTime.now()),
                        );
                        success = await controller.addCategory(newCategory);
                      } else {
                        final updatedCategory = category.copyWith(
                          name: nameController.text,
                          type: categoryType,
                          icon: selectedIcon,
                        );
                        success = await controller.updateCategory(
                          updatedCategory,
                        );
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        _showSnackBar(
                          success
                              ? (category == null
                                    ? 'Thêm danh mục thành công'
                                    : 'Cập nhật danh mục thành công')
                              : controller.errorMessage ?? 'Thao tác thất bại',
                        );
                      }
                    }
                  },
                  child: Text(category == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Danh mục'),
        backgroundColor: const Color(0xFF5CBDD9),
        bottom: TabBar(
          controller: _tabController,
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
            if (controller.isLoading)
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );

            final expenseCategories = controller.categories
                .where((c) => c.type == 'expense')
                .toList();
            final incomeCategories = controller.categories
                .where((c) => c.type == 'income')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(expenseCategories),
                _buildCategoryList(incomeCategories),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Không có danh mục nào',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white.withOpacity(0.2),
          child: ListTile(
            leading: Text(
              category.icon ?? '📁',
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              category.name,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _showCategoryDialog(category: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final controller = Provider.of<CategoryController>(
                      context,
                      listen: false,
                    );
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: Text(
                          'Bạn có chắc muốn xóa danh mục "${category.name}" không?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      bool success = await controller.deleteCategory(
                        category.id!,
                      );
                      _showSnackBar(
                        success
                            ? 'Xóa danh mục thành công'
                            : controller.errorMessage ?? 'Xóa thất bại',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
