import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';
import 'dart:async'; // Cần cho Timer
import 'package:intl/intl.dart'; // Để định dạng ngày tháng và tiền tệ

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;
  int _currentIndex = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Khởi tạo DatabaseHelper

  List<Map<String, dynamic>> _transactions = []; // Dữ liệu giao dịch từ DB
  Map<int, Map<String, dynamic>> _categoriesMap =
      {}; // Ánh xạ ID danh mục tới dữ liệu danh mục
  Map<int, Map<String, dynamic>> _accountsMap =
      {}; // Ánh xạ ID tài khoản tới dữ liệu tài khoản

  bool _isLoading = true; // Trạng thái tải dữ liệu
  String _currentTime = DateFormat(
    'HH:mm',
  ).format(DateTime.now()); // Thời gian hiện tại

  @override
  void initState() {
    super.initState();
    // Cập nhật thời gian mỗi giây
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('HH:mm').format(DateTime.now());
        });
      } else {
        timer.cancel(); // Hủy timer nếu widget không còn được gắn kết
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy dữ liệu người dùng từ arguments và tải dữ liệu từ database
    if (userData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        userData = args as Map<String, dynamic>;
        _loadData(); // Tải dữ liệu sau khi có userData
      }
    }
  }

  // Hàm tải tất cả dữ liệu cần thiết từ database
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true; // Bắt đầu tải, hiển thị loading indicator
    });

    try {
      if (userData != null && userData!['id'] != null) {
        final int userId = userData!['id'];

        // Chèn dữ liệu mẫu nếu chưa có (chỉ chạy một lần)
        await _dbHelper.insertInitialSampleData(userId);

        // Lấy danh mục và tạo map để dễ dàng tra cứu
        List<Map<String, dynamic>> categories = await _dbHelper.getCategories(
          userId,
        );
        _categoriesMap = {for (var cat in categories) cat['id'] as int: cat};

        // Lấy tài khoản và tạo map để dễ dàng tra cứu
        List<Map<String, dynamic>> accounts = await _dbHelper.getAccounts(
          userId,
        );
        _accountsMap = {for (var acc in accounts) acc['id'] as int: acc};

        // Lấy giao dịch
        List<Map<String, dynamic>> fetchedTransactions = await _dbHelper
            .getTransactions(userId);

        // Định dạng lại giao dịch để hiển thị trên UI
        _transactions =
            fetchedTransactions.map((transaction) {
              final category = _categoriesMap[transaction['category_id']];
              final account = _accountsMap[transaction['account_id']];

              String formattedAmount = NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'đ',
                decimalDigits: 0,
              ).format(transaction['amount']);
              if (transaction['type'] == 'expense') {
                formattedAmount = '-$formattedAmount';
              } else {
                formattedAmount = '+$formattedAmount';
              }

              // Chuyển đổi chuỗi ngày tháng từ DB sang định dạng dd/MM/yyyy
              final transactionDate = DateTime.parse(
                transaction['transaction_date'],
              );
              final formattedDate = DateFormat(
                'dd/MM/yyyy',
              ).format(transactionDate);

              return {
                'name': category?['name'] ?? 'Không rõ',
                'subtitle': transaction['description'] ?? '',
                'amount': formattedAmount,
                'note': account?['name'] ?? 'Không rõ',
                'avatar': _getCategoryIcon(
                  category?['name'] ?? '',
                ), // Lấy icon dựa trên tên danh mục
                'isExpense': transaction['type'] == 'expense',
                'date': formattedDate, // Ngày đã định dạng
              };
            }).toList();
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
      _showSnackBar('Không thể tải dữ liệu. Vui lòng thử lại.');
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc tải
      });
    }
  }

  // Hàm giúp lấy icon dựa trên tên danh mục (có thể mở rộng với database)
  String _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'ăn uống':
        return '🍽️';
      case 'du lịch':
        return '✈️';
      case 'tiền lương':
        return '💰';
      case 'chữa bệnh':
        return '🏥';
      case 'di chuyển':
        return '🚗';
      case 'hóa đơn':
        return '🧾';
      case 'mua sắm':
        return '🛍️';
      case 'thưởng':
        return '🎁';
      case 'thu nhập khác':
        return '📈';
      default:
        return '💸'; // Icon mặc định
    }
  }

  String _getDayName(String dateString) {
    // Chuyển đổi từ định dạng dd/MM/yyyy sang yyyy-MM-dd để parse
    final parts = dateString.split('/');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    final today = DateTime.now();
    final yesterday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: 1));
    final currentDay = DateTime(today.year, today.month, today.day);

    if (date.day == currentDay.day &&
        date.month == currentDay.month &&
        date.year == currentDay.year) {
      return 'Hôm nay';
    } else if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return 'Hôm qua';
    } else {
      final weekdays = [
        'Chủ nhật',
        'Thứ hai',
        'Thứ ba',
        'Thứ tư',
        'Thứ năm',
        'Thứ sáu',
        'Thứ bảy',
      ];
      return weekdays[date.weekday % 7];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              _buildHeader(),
              _buildChart(),
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : _buildTransactionsList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _currentTime, // Hiển thị thời gian động
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showProfileMenu,
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
                child: Image.asset(
                  'assets/profile.png', // Bạn cần thêm asset này
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, color: Colors.white, size: 30);
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                userData?['name'] ??
                    'Người dùng', // Hiển thị tên người dùng từ DB
                style: TextStyle(
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

  Widget _buildChart() {
    // BIỂU ĐỒ NÀY VẪN ĐANG SỬ DỤNG DỮ LIỆU TĨNH.
    // Để làm cho nó động, bạn sẽ cần tổng hợp dữ liệu giao dịch theo thời gian (ví dụ: hàng ngày, hàng tuần)
    // và tính toán tổng chi tiêu/thu nhập để vẽ biểu đồ.
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
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
                decoration: BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Chi tiêu',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(width: 20),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Thu nhập',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: ChartPainter(),
              size: Size(double.infinity, 100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Nhóm giao dịch theo ngày
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in _transactions) {
      String date = transaction['date'];
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sắp xếp các ngày để hiển thị gần đây nhất trước
    final sortedDates =
        groupedTransactions.keys.toList()..sort((a, b) {
          // Chuyển đổi từ định dạng dd/MM/yyyy sang yyyy-MM-dd để so sánh
          final dateA = DateFormat('dd/MM/yyyy').parse(a);
          final dateB = DateFormat('dd/MM/yyyy').parse(b);
          return dateB.compareTo(dateA);
        });

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF5CBDD9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          String date = sortedDates[index];
          List<Map<String, dynamic>> dayTransactions =
              groupedTransactions[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                      _getDayName(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              ...dayTransactions.map(
                (transaction) => _buildTransactionItem(transaction),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                transaction['avatar'], // Icon từ dữ liệu đã định dạng
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['name'], // Tên danh mục
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  transaction['subtitle'], // Mô tả giao dịch
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['amount'], // Số tiền đã định dạng
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                transaction['note'], // Tên tài khoản
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF5CBDD9),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 0
                          ? Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home_filled),
              ),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 1
                          ? Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet),
              ),
              label: 'Ví tiền',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF5CBDD9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF5CBDD9).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 3
                          ? Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pie_chart),
              ),
              label: 'Thống kê',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 4
                          ? Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings),
              ),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
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
                  margin: EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF5CBDD9),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(height: 15),
                Text(
                  userData?['name'] ?? 'Người dùng',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData?['email'] ?? 'user@example.com',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ListTile(
                  leading: Icon(Icons.person_outline, color: Color(0xFF5CBDD9)),
                  title: Text('Thông tin cá nhân'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Tính năng thông tin cá nhân sẽ sớm ra mắt');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF5CBDD9),
                  ),
                  title: Text('Cài đặt'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Tính năng cài đặt sẽ sớm ra mắt');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Color(0xFF5CBDD9)),
                  title: Text('Trợ giúp & Hỗ trợ'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Tính năng trợ giúp sẽ sớm ra mắt');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Đăng xuất'),
            content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (route) => false,
                  );
                },
                child: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }
}

// ChartPainter vẫn sử dụng dữ liệu tĩnh.
// Để làm cho nó động, bạn sẽ cần truyền dữ liệu giao dịch đã tổng hợp vào đây.
class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Sample data points for expense line (pink)
    final expensePoints = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width, size.height * 0.2),
    ];

    // Sample data points for income line (green)
    final incomePoints = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.45, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width, size.height * 0.3),
    ];

    // Draw expense line (pink) with smooth curves
    paint.color = Colors.pink;
    final expensePath = Path();
    expensePath.moveTo(expensePoints[0].dx, expensePoints[0].dy);
    for (int i = 1; i < expensePoints.length; i++) {
      final cp1x = (expensePoints[i - 1].dx + expensePoints[i].dx) / 2;
      final cp1y = expensePoints[i - 1].dy;
      final cp2x = (expensePoints[i - 1].dx + expensePoints[i].dx) / 2;
      final cp2y = expensePoints[i].dy;

      expensePath.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        expensePoints[i].dx,
        expensePoints[i].dy,
      );
    }
    canvas.drawPath(expensePath, paint);

    // Draw income line (green) with smooth curves
    paint.color = Colors.green;
    final incomePath = Path();
    incomePath.moveTo(incomePoints[0].dx, incomePoints[0].dy);
    for (int i = 1; i < incomePoints.length; i++) {
      final cp1x = (incomePoints[i - 1].dx + incomePoints[i].dx) / 2;
      final cp1y = incomePoints[i - 1].dy;
      final cp2x = (incomePoints[i - 1].dx + incomePoints[i].dx) / 2;
      final cp2y = incomePoints[i].dy;

      incomePath.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        incomePoints[i].dx,
        incomePoints[i].dy,
      );
    }
    canvas.drawPath(incomePath, paint);

    // Draw dots
    paint.style = PaintingStyle.fill;

    // Expense dots
    paint.color = Colors.pink;
    for (final point in expensePoints) {
      canvas.drawCircle(point, 4, paint);
      // Add white border
      paint.color = Colors.white;
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      paint.color = Colors.pink;
    }

    // Income dots
    paint.color = Colors.green;
    for (final point in incomePoints) {
      canvas.drawCircle(point, 4, paint);
      // Add white border
      paint.color = Colors.white;
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      paint.color = Colors.green;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
