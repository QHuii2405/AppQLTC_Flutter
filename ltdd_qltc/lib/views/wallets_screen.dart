import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';
import 'package:ltdd_qltc/models/transaction.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  double _totalBalance = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Sử dụng addPostFrameCallback để đảm bảo context đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Không cần setState ở đầu vì _isLoading đã là true
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;
    if (user == null || user.id == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final accountController = Provider.of<AccountController>(
      context,
      listen: false,
    );
    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );

    // Tải song song để tăng tốc độ
    await Future.wait([
      accountController.loadAccounts(user.id!),
      transactionController.loadTransactions(user.id!),
    ]);

    // Tính toán sau khi dữ liệu đã được tải
    double balance = accountController.accounts.fold(
      0.0,
      (sum, item) => sum + item.balance,
    );

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    double income = 0.0;
    double expense = 0.0;

    // Lọc giao dịch trong tháng hiện tại
    List<Transaction> transactionsThisMonth = transactionController.transactions
        .where((t) {
          final transactionDate = DateTime.tryParse(t.transactionDate);
          return transactionDate != null &&
              !transactionDate.isBefore(firstDayOfMonth);
        })
        .toList();

    for (var t in transactionsThisMonth) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    // Cập nhật state một lần duy nhất khi tất cả đã xong
    if (mounted) {
      setState(() {
        _totalBalance = balance;
        _monthlyIncome = income;
        _monthlyExpense = expense;
        _transactions = transactionController.transactions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ẩn nút back
        title: const Text(
          'Tài khoản của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5CBDD9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 24),
                    _buildTransactionsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng số dư',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'VND',
              decimalDigits: 0,
            ).format(_totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressBar(
            title: 'Thu nhập tháng này',
            amount: _monthlyIncome,
            total: _monthlyIncome + _monthlyExpense,
            color: const Color(0xFF34D399),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            title: 'Chi tiêu tháng này',
            amount: _monthlyExpense,
            total: _monthlyIncome + _monthlyExpense,
            color: const Color(0xFFF87171),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String title,
    required double amount,
    required double total,
    required Color color,
  }) {
    final percentage = total > 0 ? amount / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'VND',
                decimalDigits: 0,
              ).format(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage.toDouble(),
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    final homeController = Provider.of<HomeController>(context, listen: false);
    if (_transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Text(
          'Không có giao dịch nào gần đây.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
      );
    }
    // Chỉ hiển thị 15 giao dịch gần nhất
    final recentTransactions = _transactions.take(15).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentTransactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = recentTransactions[index];
        final isIncome = transaction.type == 'income';
        final formattedAmount = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: '₫',
          decimalDigits: 0,
        ).format(transaction.amount);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    transaction.categoryIcon ??
                        homeController.getCategoryIcon(
                          transaction.categoryName ?? '',
                        ),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.categoryName ?? 'Không rõ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      transaction.accountName ?? 'Ví không rõ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'} $formattedAmount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isIncome
                      ? const Color(0xFF34D399)
                      : const Color(0xFFF87171),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
