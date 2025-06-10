import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/models/category.dart';
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

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
    '💇',
    '💡',
    '💧',
    '📞',
    '⚽',
    '🎥',
    '🛒',
    '👕',
    '💊',
    '🚌',
    '🚆',
    '🚲',
    '⛽',
    '🧑‍💻',
    '🎮',
    '🎤',
    '🏞️',
    '🎓',
    '👶',
    '🐾',
    '⚙️',
    '✨',
    '🌱',
    '💍',
    '💼',
    '📊',
    '🛡️',
    '🔔',
    '🗑️',
    '🔧',
    '🔄',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthController>(
        context,
        listen: false,
      ).currentUser;
      if (user != null && user.id != null) {
        Provider.of<CategoryController>(
          context,
          listen: false,
        ).loadCategories(user.id!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;

    if (user == null) {
      _showSnackBar("Lỗi: Người dùng không tồn tại.");
      return;
    }

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
                          userId: user.id!,
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
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'CHI TIÊU'),
            Tab(text: 'THU NHẬP'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF5CBDD9),
      body: Consumer<CategoryController>(
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
              _buildCategoryGrid(expenseCategories),
              _buildCategoryGrid(incomeCategories),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      // Thêm 1 item cho nút "Thêm"
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        // Nếu là item cuối cùng, hiển thị nút "Thêm"
        if (index == categories.length) {
          return _buildAddCategoryCard();
        }

        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onLongPress: () => _showCategoryOptions(context, category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon ?? '📁', style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
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
  }

  Widget _buildAddCategoryCard() {
    return GestureDetector(
      onTap: () => _showCategoryDialog(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white.withOpacity(0.8), size: 36),
            const SizedBox(height: 8),
            Text(
              'Thêm',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryOptions(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryDialog(category: category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
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
                  bool success = await controller.deleteCategory(category.id!);
                  _showSnackBar(
                    success
                        ? 'Xóa danh mục thành công'
                        : controller.errorMessage ?? 'Xóa thất bại',
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
