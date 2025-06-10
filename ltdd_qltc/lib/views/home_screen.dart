import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';
import 'package:ltdd_qltc/models/transaction.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/views/profile_screen.dart';
import 'package:provider/provider.dart';
import 'dart:math';

// Import các màn hình con
import 'package:ltdd_qltc/views/wallets_screen.dart';
import 'package:ltdd_qltc/views/add_transaction_screen.dart';
import 'package:ltdd_qltc/views/statistics_screen.dart';
import 'package:ltdd_qltc/views/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screenOptions = [
    const HomeContent(),
    const WalletsScreen(),
    const AddTransactionScreenWrapper(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;

    if (user != null && user.id != null) {
      await Provider.of<HomeController>(
        context,
        listen: false,
      ).loadHomeData(user.id!);
      await Provider.of<TransactionController>(
        context,
        listen: false,
      ).loadTransactions(user.id!);
      await Provider.of<AccountController>(
        context,
        listen: false,
      ).loadAccounts(user.id!);
      await Provider.of<CategoryController>(
        context,
        listen: false,
      ).loadCategories(user.id!);
    } else {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (index != 2) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: _screenOptions,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTransactionScreenWrapper(),
                ),
              );
            } else {
              _pageController.jumpToPage(index);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5CBDD9),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            _buildNavItem(Icons.home_filled, 'Trang chủ', 0),
            _buildNavItem(Icons.account_balance_wallet, 'Ví tiền', 1),
            BottomNavigationBarItem(
              icon: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF5CBDD9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5CBDD9).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            _buildNavItem(Icons.pie_chart, 'Thống kê', 3),
            _buildNavItem(Icons.settings, 'Cài đặt', 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _currentIndex == index
              ? const Color(0xFF5CBDD9).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        final user = controller.currentUser;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, user),
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (user?.id != null) {
                              await controller.loadHomeData(user!.id!);
                            }
                          },
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildChart(controller),
                              _buildTransactionsList(context, controller),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentTime,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Row(
                children: [
                  Icon(
                    Icons.signal_cellular_4_bar,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.wifi, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full, color: Colors.white, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage:
                      user?.profileImageUrl != null &&
                          user!.profileImageUrl!.isNotEmpty
                      ? FileImage(File(user.profileImageUrl!))
                      : null,
                  child:
                      user?.profileImageUrl == null ||
                          user!.profileImageUrl!.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    user?.name ?? 'Người dùng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(HomeController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Thu nhập',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 20),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Chi tiêu',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: LineChart(
              incomeData: controller.incomeByMonth,
              expenseData: controller.expenseByMonth,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    HomeController controller,
  ) {
    final groupedTransactions = controller.groupedTransactions;
    final sortedDates = groupedTransactions.keys.toList()
      ..sort(
        (a, b) => DateFormat(
          'dd/MM/yyyy',
        ).parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a)),
      );

    if (controller.transactions.isEmpty && !controller.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Text(
          'Chưa có giao dịch nào.\nHãy nhấn nút "+" để bắt đầu!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
      );
    }

    return Column(
      children: sortedDates.map((date) {
        List<Transaction> dayTransactions = groupedTransactions[date]!;
        final parsedDate = DateFormat('dd/MM/yyyy').parse(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.black.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    controller.getDayName(
                      DateFormat('yyyy-MM-dd').format(parsedDate),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            ...dayTransactions.map(
              (transaction) =>
                  _buildTransactionItem(context, transaction, controller),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Transaction transaction,
    HomeController controller,
  ) {
    bool isIncome = transaction.type == 'income';
    String formattedAmount = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(transaction.amount);

    return InkWell(
      onTap: () => _showTransactionDetails(context, transaction),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      controller.getCategoryIcon(
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
                    transaction.accountName ?? '',
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
                color: isIncome ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Chi tiết giao dịch',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Loại giao dịch:',
                    transaction.type == 'income' ? 'Thu nhập' : 'Chi tiêu',
                    transaction.type == 'income' ? Colors.green : Colors.red,
                  ),
                  _buildDetailRow(
                    'Số tiền:',
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: 'VND',
                      decimalDigits: 0,
                    ).format(transaction.amount),
                  ),
                  _buildDetailRow(
                    'Danh mục:',
                    transaction.categoryName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Tài khoản:',
                    transaction.accountName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Ngày:',
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.parse(transaction.transactionDate)),
                  ),
                  _buildDetailRow(
                    'Phương thức TT:',
                    transaction.paymentMethod ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Mô tả:',
                    transaction.description != null &&
                            transaction.description!.isNotEmpty
                        ? transaction.description!
                        : 'Không có',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}

class LineChart extends StatelessWidget {
  final Map<int, double> incomeData;
  final Map<int, double> expenseData;

  const LineChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPainter(incomeData, expenseData),
      size: const Size(double.infinity, 120),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Map<int, double> incomeData;
  final Map<int, double> expenseData;
  final Paint _gridPaint;

  _ChartPainter(this.incomeData, this.expenseData)
    : _gridPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..strokeWidth = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 35.0;
    final double drawingWidth = size.width - leftPadding;
    final double maxVal = _getMaxValue();
    const double verticalPadding = 20.0;
    final double drawingHeight = size.height - verticalPadding;

    final yLabels = _generateYLabels(maxVal);
    for (int i = 0; i < yLabels.length; i++) {
      final y = drawingHeight - (i / (yLabels.length - 1)) * drawingHeight;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width, y),
        _gridPaint,
      );
      _drawText(canvas, yLabels[i], Offset(0, y - 8));
    }

    _drawXAxisLabels(canvas, size, leftPadding, drawingWidth);
    _drawLine(
      canvas,
      size,
      incomeData,
      maxVal,
      drawingHeight,
      Colors.greenAccent,
      leftPadding,
      drawingWidth,
    );
    _drawLine(
      canvas,
      size,
      expenseData,
      maxVal,
      drawingHeight,
      Colors.pinkAccent,
      leftPadding,
      drawingWidth,
    );
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    Map<int, double> data,
    double maxVal,
    double drawingHeight,
    Color color,
    double leftPadding,
    double drawingWidth,
  ) {
    if (data.isEmpty || data.values.every((v) => v == 0) || maxVal == 0) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, drawingHeight), [
        color.withOpacity(0.3),
        color.withOpacity(0.0),
      ]);

    final linePath = Path();
    final fillPath = Path();

    // Tìm tháng đầu tiên có dữ liệu để bắt đầu vẽ
    int? firstMonthWithData;
    for (int month = 1; month <= 12; month++) {
      if ((data[month] ?? 0) > 0) {
        firstMonthWithData = month;
        break;
      }
    }
    if (firstMonthWithData == null) return;

    // Điểm bắt đầu của fill path
    final firstX = leftPadding + (firstMonthWithData - 1) / 11.0 * drawingWidth;
    fillPath.moveTo(firstX, drawingHeight);

    Offset? lastPoint;

    for (int month = firstMonthWithData; month <= 12; month++) {
      final value = data[month] ?? 0;
      final x = leftPadding + (month - 1) / 11.0 * drawingWidth;
      final y = drawingHeight - (value / maxVal) * drawingHeight;
      final currentPoint = Offset(x, y);

      if (lastPoint == null) {
        linePath.moveTo(currentPoint.dx, currentPoint.dy);
        fillPath.lineTo(currentPoint.dx, currentPoint.dy);
      } else {
        final prevX = lastPoint.dx;
        final prevY = lastPoint.dy;
        final controlPoint1 = Offset(prevX + (x - prevX) / 2, prevY);
        final controlPoint2 = Offset(prevX + (x - prevX) / 2, y);
        linePath.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          x,
          y,
        );
        fillPath.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          x,
          y,
        );
      }
      lastPoint = currentPoint;
    }

    if (lastPoint != null) {
      fillPath.lineTo(lastPoint.dx, drawingHeight);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(linePath, linePaint);
  }

  void _drawXAxisLabels(
    Canvas canvas,
    Size size,
    double leftPadding,
    double drawingWidth,
  ) {
    for (int i = 1; i <= 6; i++) {
      final month = i * 2;
      final x = leftPadding + (month - 1) / 11.0 * drawingWidth;
      _drawText(canvas, 'Tháng $month', Offset(x - 20, size.height - 15));
    }
  }

  double _getMaxValue() {
    double maxVal = 0;
    incomeData.values.forEach((val) => maxVal = max(maxVal, val));
    expenseData.values.forEach((val) => maxVal = max(maxVal, val));
    return maxVal == 0 ? 1000000 : maxVal * 1.2;
  }

  List<String> _generateYLabels(double maxVal) {
    if (maxVal < 1) return ['0'];
    final List<String> labels = [];
    final double step = maxVal / 4;
    for (int i = 0; i <= 4; i++) {
      final value = i * step;
      if (value >= 1000000) {
        labels.add('${(value / 1000000).toStringAsFixed(0)}M');
      } else if (value >= 1000) {
        labels.add('${(value / 1000).toStringAsFixed(0)}K');
      } else {
        labels.add(value.toStringAsFixed(0));
      }
    }
    return labels;
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 40);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
