import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/controllers/transaction_controller.dart';
import 'package:flutter_application_1/controllers/category_controller.dart';
import 'package:flutter_application_1/controllers/wallet_controller.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/models/transaction.dart';
import 'package:flutter_application_1/models/category.dart';
import 'package:flutter_application_1/models/account.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  User? _loggedInUser;
  String _transactionType = 'expense'; // 'expense' or 'income'
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Category? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loggedInUser == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
        if (_loggedInUser!.id != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<CategoryController>(
              context,
              listen: false,
            ).loadCategories(_loggedInUser!.id!);
            Provider.of<WalletController>(
              context,
              listen: false,
            ).loadWallets(_loggedInUser!.id!);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF5CBDD9),
            colorScheme: const ColorScheme.light(primary: Color(0xFF5CBDD9)),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTransaction() async {
    if (_loggedInUser?.id == null) {
      _showSnackBar('Lỗi: Không tìm thấy thông tin người dùng.');
      return;
    }
    if (_amountController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedAccount == null) {
      _showSnackBar('Vui lòng điền đầy đủ số tiền, danh mục và tài khoản.');
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      _showSnackBar('Số tiền phải lớn hơn 0.');
      return;
    }

    final newTransaction = Transaction(
      userId: _loggedInUser!.id!,
      type: _transactionType,
      categoryId: _selectedCategory!.id!,
      amount: amount,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      transactionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      paymentMethod: 'Tiền mặt', // Placeholder, có thể thêm lựa chọn sau
      accountId: _selectedAccount!.id!,
      createdAt: DateTime.now().toIso8601String(),
    );

    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    bool success = await transactionController.addTransaction(newTransaction);

    if (success) {
      _showSnackBar('Thêm giao dịch thành công!');
      Navigator.pop(context); // Quay lại màn hình trước
    } else {
      _showSnackBar(
        transactionController.errorMessage ?? 'Thêm giao dịch thất bại.',
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm giao dịch',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5CBDD9),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        child: Consumer3<
          CategoryController,
          WalletController,
          TransactionController
        >(
          builder: (
            context,
            categoryController,
            walletController,
            transactionController,
            child,
          ) {
            if (categoryController.isLoading || walletController.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Loại giao dịch
                  _buildSectionTitle('Chọn loại giao dịch'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTransactionTypeButton(
                          'expense',
                          'Chi tiêu',
                          Icons.arrow_upward,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTransactionTypeButton(
                          'income',
                          'Thu nhập',
                          Icons.arrow_downward,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Số tiền
                  _buildSectionTitle('Số tiền'),
                  _buildTextField(
                    controller: _amountController,
                    hintText: 'Nhập số tiền',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Danh mục
                  _buildSectionTitle('Danh mục'),
                  _buildDropdownField<Category>(
                    hintText: 'Chọn danh mục',
                    icon: Icons.category_outlined,
                    value: _selectedCategory,
                    items:
                        categoryController.categories
                            .where((cat) => cat.type == _transactionType)
                            .map((category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(
                                  '${category.icon ?? ''} ${category.name}',
                                ),
                              );
                            })
                            .toList(),
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tài khoản
                  _buildSectionTitle('Tài khoản'),
                  _buildDropdownField<Account>(
                    hintText: 'Chọn tài khoản',
                    icon: Icons.account_balance_wallet_outlined,
                    value: _selectedAccount,
                    items:
                        walletController.wallets.map((account) {
                          return DropdownMenuItem<Account>(
                            value: account,
                            child: Text(
                              '${account.name} (${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(account.balance)})',
                            ),
                          );
                        }).toList(),
                    onChanged: (Account? newValue) {
                      setState(() {
                        _selectedAccount = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Ngày giao dịch
                  _buildSectionTitle('Ngày giao dịch'),
                  _buildDateField(context),
                  const SizedBox(height: 20),

                  // Mô tả
                  _buildSectionTitle('Mô tả (Tùy chọn)'),
                  _buildTextField(
                    controller: _descriptionController,
                    hintText: 'Mô tả giao dịch',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed:
                        transactionController.isLoading
                            ? null
                            : _addTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child:
                        transactionController.isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Lưu giao dịch',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTransactionTypeButton(String type, String label, IconData icon) {
    bool isSelected = _transactionType == type;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _transactionType = type;
          _selectedCategory = null; // Reset danh mục khi đổi loại
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.white : Colors.white.withOpacity(0.15),
        foregroundColor: isSelected ? const Color(0xFF5CBDD9) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFF5CBDD9) : Colors.white30,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String hintText,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hintText,
            style: const TextStyle(color: Colors.white60, fontSize: 15),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          isExpanded: true,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ), // Màu chữ cho item được chọn
          dropdownColor: Colors.white, // Màu nền của dropdown
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
