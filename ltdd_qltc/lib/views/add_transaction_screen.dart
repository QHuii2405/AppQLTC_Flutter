import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/category.dart';
import 'package:ltdd_qltc/models/account.dart';
import 'package:ltdd_qltc/models/transaction.dart' as app_transaction;
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';

class AddTransactionScreenWrapper extends StatelessWidget {
  const AddTransactionScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Lỗi: Người dùng không tồn tại.")),
      );
    }
    return AddTransactionScreen(user: user);
  }
}

class AddTransactionScreen extends StatefulWidget {
  final User user;
  const AddTransactionScreen({super.key, required this.user});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'expense';
  Category? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
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

  Future<void> _addTransaction() async {
    if (!mounted) return;

    final amountText = _amountController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
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
    if (_selectedType == 'expense' && amount > _selectedAccount!.balance) {
      _showSnackBar('Số tiền chi tiêu vượt quá số dư trong ví.');
      return;
    }

    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    final accountController = Provider.of<AccountController>(
      context,
      listen: false,
    );
    final homeController = Provider.of<HomeController>(context, listen: false);

    final newTransaction = app_transaction.Transaction(
      userId: widget.user.id!,
      type: _selectedType,
      categoryId: _selectedCategory!.id!,
      amount: amount,
      description: _descriptionController.text.trim(),
      transactionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      paymentMethod: _selectedPaymentMethod,
      accountId: _selectedAccount!.id!,
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    bool addSuccess = await transactionController.addTransaction(
      newTransaction,
    );
    if (!mounted) return;

    if (addSuccess) {
      double newBalance = _selectedType == 'income'
          ? _selectedAccount!.balance + amount
          : _selectedAccount!.balance - amount;

      final updatedAccount = _selectedAccount!.copyWith(balance: newBalance);
      await accountController.updateAccount(updatedAccount);

      await homeController.loadHomeData(widget.user.id!);

      _showSnackBar('Thêm giao dịch thành công!');
      if (mounted) Navigator.of(context).pop();
    } else {
      _showSnackBar(
        transactionController.errorMessage ?? 'Thêm giao dịch thất bại.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4BAFCC),
      appBar: AppBar(
        title: const Text('Thêm Giao Dịch'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTypeSelection(),
              const SizedBox(height: 20),
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              _buildAccountDropdown(),
              const SizedBox(height: 20),
              _buildDescriptionInput(),
              const SizedBox(height: 20),
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildPaymentMethodDropdown(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Thêm Giao Dịch',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ToggleButtons(
        isSelected: [_selectedType == 'expense', _selectedType == 'income'],
        onPressed: (index) {
          setState(() {
            _selectedType = (index == 0) ? 'expense' : 'income';
            _selectedCategory = null;
          });
        },
        fillColor: const Color(0xFF2196F3),
        selectedColor: Colors.white,
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12),
        borderColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text('Chi tiêu'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text('Thu nhập'),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 24),
      decoration: InputDecoration(
        labelText: 'Số tiền',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.attach_money, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoryController>(
      builder: (context, controller, child) {
        final categories = controller.categories
            .where((cat) => cat.type == _selectedType)
            .toList();

        Category? currentSelection = _selectedCategory;
        if (currentSelection != null &&
            !categories.contains(currentSelection)) {
          currentSelection = null;
        }

        return DropdownButtonFormField<Category>(
          value: currentSelection,
          hint: const Text(
            'Chọn danh mục',
            style: TextStyle(color: Colors.white70),
          ),
          dropdownColor: const Color(0xFF4BAFCC),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            prefixIcon: const Icon(
              Icons.category_outlined,
              color: Colors.white70,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (Category? newValue) {
            setState(() => _selectedCategory = newValue);
          },
          // SỬA LỖI: Cập nhật items để hiển thị icon
          items: categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Row(
                children: [
                  Text(
                    category.icon ?? '📁',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAccountDropdown() {
    return Consumer<AccountController>(
      builder: (context, controller, child) {
        Account? currentSelection = _selectedAccount;
        if (currentSelection != null &&
            !controller.accounts.contains(currentSelection)) {
          currentSelection = null;
        }

        return DropdownButtonFormField<Account>(
          value: currentSelection,
          hint: const Text(
            'Chọn ví tiền',
            style: TextStyle(color: Colors.white70),
          ),
          dropdownColor: const Color(0xFF4BAFCC),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            prefixIcon: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white70,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (Account? newValue) {
            setState(() => _selectedAccount = newValue);
          },
          items: controller.accounts.map((Account account) {
            return DropdownMenuItem<Account>(
              value: account,
              child: Text(account.name),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDescriptionInput() {
    return TextField(
      controller: _descriptionController,
      maxLines: 2,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Mô tả (tùy chọn)',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(
          Icons.description_outlined,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextField(
      readOnly: true,
      controller: TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
      ),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Ngày giao dịch',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethod,
      hint: const Text(
        'Phương thức thanh toán (tùy chọn)',
        style: TextStyle(color: Colors.white70),
      ),
      dropdownColor: const Color(0xFF4BAFCC),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        prefixIcon: const Icon(Icons.payment_outlined, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedPaymentMethod = newValue;
        });
      },
      items: _paymentMethods.map((String method) {
        return DropdownMenuItem<String>(value: method, child: Text(method));
      }).toList(),
    );
  }
}
