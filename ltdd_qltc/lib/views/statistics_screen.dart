import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';
import 'package:ltdd_qltc/models/transaction.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedPeriod = 'Tháng'; // 'Tháng' hoặc 'Tuần'

  List<Transaction> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;
    if (user == null || user.id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    await transactionController.loadTransactions(user.id!);
    if (mounted) {
      setState(() {
        _allTransactions = transactionController.transactions;
        _isLoading = false;
      });
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF5CBDD9),
        title: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildStatsContent('expense'),
                  _buildStatsContent('income'),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsContent(String type) {
    final transactions = _allTransactions.where((t) => t.type == type).toList();
    final totalAmount = transactions.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    final Map<String, double> barChartData = _selectedPeriod == 'Tháng'
        ? _prepareMonthlyData(transactions)
        : _prepareWeeklyData(transactions);

    final pieChartData = _preparePieChartData(transactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type == 'expense' ? 'Tổng chi tiêu' : 'Tổng thu nhập',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'VND',
              decimalDigits: 0,
            ).format(totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader("Thống kê theo", _buildPeriodSelector()),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            height: 250,
            child: BarChart(data: barChartData),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader("So sánh các loại", null),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: DonutChart(data: pieChartData),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pieChartData.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: entry.value.color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${entry.key} (${entry.value.percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Widget? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 25,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ToggleButtons(
        isSelected: [_selectedPeriod == 'Tuần', _selectedPeriod == 'Tháng'],

        onPressed: (index) {
          setState(() {
            _selectedPeriod = (index == 0) ? 'Tuần' : 'Tháng';
          });
        },
        color: Colors.white70,
        selectedColor: Colors.white,
        fillColor: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        borderWidth: 0,
        selectedBorderColor: Colors.white,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Tuần'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Tháng'),
          ),
        ],
      ),
    );
  }

  Map<String, double> _prepareMonthlyData(List<Transaction> transactions) {
    final Map<int, double> monthlyTotals = {
      for (var i = 1; i <= 12; i++) i: 0.0,
    };
    final currentYear = DateTime.now().year;

    for (var transaction in transactions) {
      final date = DateTime.tryParse(transaction.transactionDate);
      if (date != null && date.year == currentYear) {
        monthlyTotals.update(
          date.month,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
    return monthlyTotals.map((key, value) => MapEntry('T$key', value));
  }

  Map<String, double> _prepareWeeklyData(List<Transaction> transactions) {
    final Map<String, double> weeklyTotals = {};
    final now = DateTime.now();

    for (int i = 3; i >= 0; i--) {
      final startOfWeek = now.subtract(
        Duration(days: now.weekday - 1 + (i * 7)),
      );
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final weekKey =
          '${DateFormat('dd/MM').format(startOfWeek)}-${DateFormat('dd/MM').format(endOfWeek)}';

      weeklyTotals[weekKey] = 0.0;

      for (var transaction in transactions) {
        final date = DateTime.tryParse(transaction.transactionDate);
        if (date != null &&
            !date.isBefore(startOfWeek) &&
            date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          weeklyTotals.update(weekKey, (value) => value + transaction.amount);
        }
      }
    }
    return weeklyTotals;
  }

  Map<String, PieData> _preparePieChartData(List<Transaction> transactions) {
    final Map<String, double> categoryTotals = {};
    double total = transactions.fold(0.0, (sum, item) => sum + item.amount);

    if (total == 0) return {};

    for (var transaction in transactions) {
      final categoryName = transaction.categoryName ?? 'Khác';
      categoryTotals.update(
        categoryName,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.yellow,
      Colors.cyan,
      Colors.pink,
    ];
    int colorIndex = 0;

    final Map<String, PieData> pieData = {};
    categoryTotals.forEach((key, value) {
      pieData[key] = PieData(
        percentage: (value / total) * 100,
        color: colors[colorIndex % colors.length],
      );
      colorIndex++;
    });

    return pieData;
  }
}

class PieData {
  final double percentage;
  final Color color;
  PieData({required this.percentage, required this.color});
}

class BarChart extends StatelessWidget {
  final Map<String, double> data;
  const BarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.values.every((e) => e == 0)) {
      return const Center(
        child: Text(
          'Không có dữ liệu trong khoảng thời gian này',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    final maxValue = data.values.fold(0.0, (max, v) => v > max ? v : max);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = (constraints.maxWidth / data.length) * 0.5;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: data.entries.map((entry) {
            final barHeight = maxValue > 0
                ? (entry.value / maxValue) * (constraints.maxHeight - 20)
                : 0.0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class DonutChart extends StatelessWidget {
  final Map<String, PieData> data;
  const DonutChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return CustomPaint(
      painter: _DonutChartPainter(data),
      size: const Size(150, 150),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, PieData> data;
  _DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double totalPercentage = 0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 30.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    data.forEach((key, value) {
      final sweepAngle = (value.percentage / 100) * 2 * pi;
      final startAngle = (totalPercentage / 100) * 2 * pi - (pi / 2);

      final paint = Paint()
        ..color = value.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      totalPercentage += value.percentage;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
