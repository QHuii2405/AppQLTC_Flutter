import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';
import 'package:ltdd_qltc/models/transaction.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui' as ui;

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
  String _currentTime = DateFormat('HH:mm').format(DateTime.now());
  bool _dataLoaded = false;

  late PageController _pageController;
  late List<Widget> _screenOptions;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screenOptions = [
      _buildLoadingScreen(), // Placeholder
      _buildLoadingScreen(),
      _buildLoadingScreen(),
      _buildLoadingScreen(),
      _buildLoadingScreen(),
    ];

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('HH:mm').format(DateTime.now());
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final homeController = Provider.of<HomeController>(
            context,
            listen: false,
          );
          homeController.updateCurrentUser(args);
          if (args.id != null) {
            homeController.loadHomeData(args.id!).then((_) {
              if (mounted) {
                setState(() {
                  _screenOptions = [
                    _buildHomeContent(),
                    WalletsScreen(user: args),
                    AddTransactionScreen(user: args),
                    StatisticsScreen(user: args),
                    SettingsScreen(user: args),
                  ];
                  _dataLoaded = true;
                });
              }
            });
          } else {
            Navigator.pushReplacementNamed(context, '/signin');
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/signin');
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
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

  Widget _buildHomeContent() {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
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
                _buildStatusBar(),
                _buildHeader(controller.currentUser),
                controller.isLoading
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            if (controller.currentUser?.id != null) {
                              await controller.loadHomeData(
                                controller.currentUser!.id!,
                              );
                            }
                          },
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildChart(controller),
                              _buildTransactionsList(controller),
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

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _currentTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Icon(Icons.wifi, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Icon(Icons.battery_full, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showProfileMenu(user),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child:
                    user?.profileImageUrl != null &&
                        user!.profileImageUrl!.isNotEmpty
                    ? Image.network(
                        user.profileImageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 30),
              ),
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

  Widget _buildTransactionsList(HomeController controller) {
    final groupedTransactions = controller.groupedTransactions;
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd/MM/yyyy').parse(a);
        final dateB = DateFormat('dd/MM/yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String date = sortedDates[index];
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
              (transaction) => _buildTransactionItem(transaction, controller),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(
    Transaction transaction,
    HomeController controller,
  ) {
    bool isIncome = transaction.type == 'income';
    String formattedAmount = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(transaction.amount);

    return Container(
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
                    controller.getCategoryIcon(transaction.categoryName ?? ''),
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
              color: isIncome ? Colors.greenAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final user = Provider.of<HomeController>(
      context,
      listen: false,
    ).currentUser;
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
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(user: user),
                  ),
                );
              }
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

  void _showProfileMenu(User? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthController>(context, listen: false).signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
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
    final double maxVal = _getMaxValue();
    const double minVal = 0;

    // Draw horizontal grid lines and labels
    final yLabels = _generateYLabels(maxVal);
    for (int i = 0; i < yLabels.length; i++) {
      final y = size.height - (i / (yLabels.length - 1)) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
      _drawText(canvas, yLabels[i], Offset(-35, y - 8));
    }

    _drawXAxisLabels(canvas, size);

    // Draw lines for income and expense
    _drawLine(canvas, size, incomeData, maxVal, minVal, Colors.greenAccent);
    _drawLine(canvas, size, expenseData, maxVal, minVal, Colors.pinkAccent);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    Map<int, double> data,
    double maxVal,
    double minVal,
    Color color,
  ) {
    if (data.isEmpty || data.values.every((v) => v == 0)) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final List<int> sortedMonths = data.keys.where((k) => data[k]! > 0).toList()
      ..sort();
    if (sortedMonths.isEmpty) return;

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final value = data[month] ?? 0;

      final x = (month - 1) / 11 * size.width;
      final y =
          size.height - ((value - minVal) / (maxVal - minVal)) * size.height;
      final point = Offset(x, y.isNaN ? size.height : y);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        final prevMonth = sortedMonths[i - 1];
        final prevValue = data[prevMonth] ?? 0;
        final prevX = (prevMonth - 1) / 11 * size.width;
        final prevY =
            size.height -
            ((prevValue - minVal) / (maxVal - minVal)) * size.height;
        final prevPoint = Offset(prevX, prevY.isNaN ? size.height : prevY);

        final controlPoint1 = Offset(
          prevPoint.dx + (point.dx - prevPoint.dx) / 2,
          prevPoint.dy,
        );
        final controlPoint2 = Offset(
          prevPoint.dx + (point.dx - prevPoint.dx) / 2,
          point.dy,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          point.dx,
          point.dy,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawXAxisLabels(Canvas canvas, Size size) {
    for (int i = 1; i <= 6; i++) {
      final month = i * 2;
      final x = (month - 2) / 11 * size.width; // Adjusted for better centering
      _drawText(canvas, 'Tháng ${month}', Offset(x, size.height + 5));
    }
  }

  double _getMaxValue() {
    double maxVal = 0;
    incomeData.values.forEach((val) => maxVal = max(maxVal, val));
    expenseData.values.forEach((val) => maxVal = max(maxVal, val));
    return maxVal == 0 ? 1000000 : maxVal * 1.2;
  }

  List<String> _generateYLabels(double maxVal) {
    if (maxVal <= 1) return ['0', '1'];

    final List<String> labels = [];
    final double step = maxVal / 4;
    for (int i = 0; i < 5; i++) {
      final value = i * step;
      if (value >= 1000000) {
        labels.add('${(value / 1000000).toStringAsFixed(0)}M');
      } else if (value >= 1000) {
        labels.add('${(value / 1000).toStringAsFixed(0)}K');
      } else {
        labels.add(value.toStringAsFixed(0));
      }
    }
    return labels.reversed.toList();
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
