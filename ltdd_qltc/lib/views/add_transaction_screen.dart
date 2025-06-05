import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày tháng và số tiền
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/category.dart';
import 'package:ltdd_qltc/models/account.dart';
import 'package:ltdd_qltc/models/transaction.dart' as app_transaction;
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  final User user;
  const AddTransactionScreen({super.key, required this.user});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'expense'; // Mặc định là chi tiêu
  Category? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now(); // Mặc định là ngày hôm nay
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = [
    'Tiền mặt',
    'Chuyển khoản',
    'Thẻ tín dụng',
    'Thẻ ghi nợ',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user.id != null) {
        Provider.of<CategoryController>(
          context,
          listen: false,
        ).loadCategories(widget.user.id!);
        Provider.of<AccountController>(
          context,
          listen: false,
        ).loadAccounts(widget.user.id!);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addTransaction() async {
    // Kiểm tra mounted ngay từ đầu hàm bất đồng bộ
    if (!mounted) return;

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showSnackBar('Vui lòng nhập số tiền.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Số tiền không hợp lệ.');
      return;
    }

    if (_selectedCategory == null) {
      _showSnackBar('Vui lòng chọn danh mục.');
      return;
    }

    if (_selectedAccount == null) {
      _showSnackBar('Vui lòng chọn ví tiền.');
      return;
    }

    if (widget.user.id == null) {
      _showSnackBar('Lỗi: Không tìm thấy thông tin người dùng.');
      print('AddTransactionScreen: User ID is null, cannot add transaction.');
      return;
    }

    if (_selectedType == 'expense' && amount > _selectedAccount!.balance) {
      _showSnackBar('Số tiền chi tiêu vượt quá số dư hiện có trong ví.');
      return;
    }

    // Lấy controller trước khối try-catch để đảm bảo có sẵn
    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    final homeController = Provider.of<HomeController>(context, listen: false);
    final accountController = Provider.of<AccountController>(
      context,
      listen: false,
    );

    try {
      final newTransaction = app_transaction.Transaction(
        userId: widget.user.id!,
        type: _selectedType,
        categoryId: _selectedCategory!.id!,
        amount: amount,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        transactionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        paymentMethod: _selectedPaymentMethod,
        accountId: _selectedAccount!.id!,
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );

      bool addSuccess = await transactionController.addTransaction(
        newTransaction,
      );
      if (!mounted) return; // Kiểm tra mounted sau await
      if (!addSuccess) {
        _showSnackBar(
          transactionController.errorMessage ?? 'Thêm giao dịch thất bại.',
        );
        return;
      }

      // Lấy lại _selectedAccount từ controller để đảm bảo nó là đối tượng mới nhất
      Account? currentSelectedAccount = accountController.accounts.firstWhere(
        (acc) => acc.id == _selectedAccount!.id,
        orElse: () => _selectedAccount!,
      );

      double updatedBalance = currentSelectedAccount.balance;
      if (_selectedType == 'income') {
        updatedBalance += amount;
      } else {
        updatedBalance -= amount;
      }

      final updatedAccount = currentSelectedAccount.copyWith(
        balance: updatedBalance,
      );
      bool updateAccountSuccess = await accountController.updateAccount(
        updatedAccount,
      );
      if (!mounted) return; // Kiểm tra mounted sau await
      if (!updateAccountSuccess) {
        _showSnackBar(
          accountController.errorMessage ??
              'Cập nhật số dư ví tiền thất bại. Giao dịch đã được thêm nhưng số dư ví không được cập nhật.',
        );
        return;
      }

      await homeController.loadHomeData(widget.user.id!);
      if (!mounted) return; // Kiểm tra mounted sau await

      _showSnackBar('Thêm giao dịch thành công!');

      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedType = 'expense';
        _selectedCategory = null;
        _selectedAccount = null;
        _selectedDate = DateTime.now();
        _selectedPaymentMethod = null;
      });
    } catch (e) {
      _showSnackBar('Lỗi khi thêm giao dịch: $e');
      print('AddTransactionScreen - Lỗi thêm giao dịch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Thêm Giao Dịch',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5CBDD9),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child:
                  Consumer3<
                    CategoryController,
                    AccountController,
                    TransactionController
                  >(
                    builder:
                        (
                          context,
                          categoryController,
                          accountController,
                          transactionController,
                          child,
                        ) {
                          final expenseCategories = categoryController
                              .categories
                              .where((cat) => cat.type == 'expense')
                              .toList();
                          final incomeCategories = categoryController.categories
                              .where((cat) => cat.type == 'income')
                              .toList();
                          final availableAccounts = accountController.accounts;

                          if (categoryController.isLoading ||
                              accountController.isLoading ||
                              transactionController.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTypeSelection(),
                                const SizedBox(height: 20),

                                _buildAmountInput(),
                                const SizedBox(height: 20),

                                _buildCategoryDropdown(
                                  _selectedType == 'expense'
                                      ? expenseCategories
                                      : incomeCategories,
                                  categoryController,
                                ),
                                const SizedBox(height: 20),

                                if (availableAccounts.isEmpty)
                                  _buildNoAccountMessage()
                                else
                                  _buildAccountDropdown(
                                    availableAccounts,
                                    accountController,
                                  ),
                                const SizedBox(height: 20),

                                _buildDescriptionInput(),
                                const SizedBox(height: 20),

                                _buildDatePicker(),
                                const SizedBox(height: 20),

                                _buildPaymentMethodDropdown(),
                                // Giảm padding cuối cùng hoặc loại bỏ nếu thấy thừa
                                const SizedBox(height: 30),

                                ElevatedButton(
                                  onPressed: _addTransaction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Thêm Giao Dịch',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: ToggleButtons(
          isSelected: [_selectedType == 'expense', _selectedType == 'income'],
          onPressed: (index) {
            setState(() {
              _selectedType = (index == 0) ? 'expense' : 'income';
              _selectedCategory = null;
            });
          },
          fillColor: Colors.white.withOpacity(0.3),
          selectedColor: Colors.white,
          color: Colors.white70,
          borderColor: Colors.transparent,
          selectedBorderColor: Colors.transparent,
          splashColor: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Text(
                'Chi tiêu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Text(
                'Thu nhập',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: 'Số tiền',
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: '0.00',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.attach_money, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
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

  Widget _buildCategoryDropdown(
    List<Category> categories,
    CategoryController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          value: _selectedCategory,
          hint: Text(
            'Chọn danh mục',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: const Color(0xFF4BAFCC),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          isExpanded: true,
          onChanged: (Category? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          items: categories.map<DropdownMenuItem<Category>>((
            Category category,
          ) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Row(
                children: [
                  Text(
                    category.icon ?? controller.getCategoryIcon(category.name),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(category.name)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown(
    List<Account> accounts,
    AccountController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Account>(
          value: _selectedAccount,
          hint: Text(
            'Chọn ví tiền',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: const Color(0xFF4BAFCC),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          isExpanded: true,
          onChanged: (Account? newValue) {
            setState(() {
              _selectedAccount = newValue;
            });
          },
          items: accounts.map<DropdownMenuItem<Account>>((Account account) {
            return DropdownMenuItem<Account>(
              value: account,
              child: Text(
                '${account.name} (${NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(account.balance)})',
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNoAccountMessage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70, size: 30),
          const SizedBox(height: 10),
          Text(
            'Bạn chưa có ví tiền nào. Vui lòng tạo ví mới trong mục "Cài đặt" -> "Quản lý ví tiền" để thêm giao dịch.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/settings',
                arguments: widget.user,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đi tới Cài đặt'),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return TextField(
      controller: _descriptionController,
      keyboardType: TextInputType.text,
      maxLines: 3,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Mô tả (Tùy chọn)',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(
          Icons.description_outlined,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
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

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Colors.white70),
          const SizedBox(width: 16),
          Text(
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPaymentMethod,
          hint: Text(
            'Phương thức thanh toán (Tùy chọn)',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: const Color(0xFF4BAFCC),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedPaymentMethod = newValue;
            });
          },
          items: _paymentMethods.map<DropdownMenuItem<String>>((String method) {
            return DropdownMenuItem<String>(value: method, child: Text(method));
          }).toList(),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
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
