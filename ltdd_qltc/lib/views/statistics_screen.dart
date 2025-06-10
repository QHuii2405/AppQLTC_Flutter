import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';
import 'package:ltdd_qltc/models/transaction.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class StatisticsScreen extends StatefulWidget {
  final User user;
  const StatisticsScreen({super.key, required this.user});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Tháng';
  String _selectedYear = DateTime.now().year.toString();
  bool _isLoading = true;

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
    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    await transactionController.loadTransactions(widget.user.id!);
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

    // Data for Bar Chart
    final barChartData = _prepareBarChartData(transactions);

    // Data for Pie Chart
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

          _buildSectionTitle('Thống kê chi tiêu theo tháng'),
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

          _buildSectionTitle('So sánh các loại'),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Map<String, double> _prepareBarChartData(List<Transaction> transactions) {
    final Map<int, double> monthlyTotals = {};
    for (int i = 1; i <= 12; i++) {
      monthlyTotals[i] = 0.0;
    }

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

  Map<String, PieData> _preparePieChartData(List<Transaction> transactions) {
    final Map<String, double> categoryTotals = {};
    double total = 0;

    for (var transaction in transactions) {
      final categoryName = transaction.categoryName ?? 'Khác';
      categoryTotals.update(
        categoryName,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
      total += transaction.amount;
    }

    if (total == 0) return {};

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

// ----- Chart Widgets -----
class BarChart extends StatelessWidget {
  final Map<String, double> data;
  const BarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.values.every((e) => e == 0)) {
      return const Center(
        child: Text(
          'Không có dữ liệu cho năm nay',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    final maxValue = data.values.fold(0.0, (max, v) => v > max ? v : max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: data.entries.map((entry) {
        final barHeight = maxValue > 0 ? (entry.value / maxValue) * 200 : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20,
              height: barHeight < 0 ? 0 : barHeight,
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
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class PieData {
  final double percentage;
  final Color color;
  PieData({required this.percentage, required this.color});
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
    final strokeWidth = 30.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    data.forEach((key, value) {
      final sweepAngle = (value.percentage / 100) * 2 * pi;
      final startAngle = (totalPercentage / 100) * 2 * pi - pi / 2;

      final paint = Paint()
        ..color = value.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      totalPercentage += value.percentage;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
