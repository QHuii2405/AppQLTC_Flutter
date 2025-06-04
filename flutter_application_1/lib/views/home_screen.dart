import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/controllers/home_controller.dart';
import 'package:flutter_application_1/models/user.dart'; // Import User model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _loggedInUser; // Lưu trữ đối tượng User đã đăng nhập
  int _currentIndex = 0;
  String _currentTime = DateFormat('HH:mm').format(DateTime.now());
  bool _dataLoaded = false; // Cờ để đảm bảo loadHomeData chỉ chạy một lần

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
        timer.cancel();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy dữ liệu người dùng từ arguments CHỈ KHI CHƯA CÓ và CHƯA TẢI DỮ LIỆU
    if (_loggedInUser == null && !_dataLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
        // Tải dữ liệu cho HomeScreen thông qua Controller
        // Đảm bảo _loggedInUser.id không null trước khi gọi
        if (_loggedInUser!.id != null) {
          // Đặt cuộc gọi loadHomeData vào một callback sau khi khung hình hoàn thành
          // Điều này giúp tránh lỗi "setState() or markNeedsBuild() called during build"
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<HomeController>(
              context,
              listen: false,
            ).updateCurrentUser(_loggedInUser!);
            Provider.of<HomeController>(
              context,
              listen: false,
            ).loadHomeData(_loggedInUser!.id!);
            _dataLoaded = true; // Đặt cờ là true sau khi tải dữ liệu
          });
        } else {
          print('Lỗi: ID người dùng là null trong HomeScreen.');
          _showSnackBar('Lỗi tải dữ liệu: Không tìm thấy ID người dùng.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ HomeController
    return Consumer<HomeController>(
      builder: (context, controller, child) {
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
                  _buildHeader(
                    controller.currentUser,
                  ), // Truyền currentUser từ controller
                  _buildChart(), // Biểu đồ vẫn tĩnh, cần dữ liệu từ controller để làm động
                  Expanded(
                    child:
                        controller.isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : _buildTransactionsList(
                              controller,
                            ), // Truyền controller để lấy transactions
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(controller),
        );
      },
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _currentTime,
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

  Widget _buildHeader(User? user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showProfileMenu(user), // Truyền user vào menu
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
                            return Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            );
                          },
                        )
                        : Icon(Icons.person, color: Colors.white, size: 30),
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
                user?.name ?? 'Người dùng',
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
              painter: ChartPainter(), // Vẫn là biểu đồ tĩnh
              size: Size(double.infinity, 100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(HomeController controller) {
    // Nhóm giao dịch theo ngày
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var transaction in controller.transactions) {
      // Chuyển đổi từ định dạng YYYY-MM-DD sang DD/MM/YYYY để nhóm
      final formattedDate = DateFormat(
        'dd/MM/yyyy',
      ).format(DateFormat('yyyy-MM-dd').parse(transaction.transactionDate));
      if (!groupedTransactions.containsKey(formattedDate)) {
        groupedTransactions[formattedDate] = [];
      }
      groupedTransactions[formattedDate]!.add(transaction);
    }

    // Sắp xếp các ngày để hiển thị gần đây nhất trước
    final sortedDates =
        groupedTransactions.keys.toList()..sort((a, b) {
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
          List<Transaction> dayTransactions = groupedTransactions[date]!;

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
                      controller.getDayName(
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateFormat('dd/MM/yyyy').parse(date)),
                      ), // Lấy tên ngày
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
      ),
    );
  }

  Widget _buildTransactionItem(
    Transaction transaction,
    HomeController controller,
  ) {
    String formattedAmount = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(transaction.amount);
    if (transaction.type == 'expense') {
      formattedAmount = '-$formattedAmount';
    } else {
      formattedAmount = '+$formattedAmount';
    }

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
                transaction.categoryIcon ??
                    controller.getCategoryIcon(
                      transaction.categoryName ?? '',
                    ), // Icon từ DB hoặc mặc định
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
                  transaction.categoryName ?? 'Không rõ', // Tên danh mục từ DB
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  transaction.description ?? '', // Mô tả giao dịch
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
                formattedAmount, // Số tiền đã định dạng
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                transaction.accountName ?? 'Không rõ', // Tên tài khoản từ DB
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

  Widget _buildBottomNavigationBar(HomeController controller) {
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
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });

              switch (index) {
                case 0: // Trang chủ (đã ở đây)
                  // Không làm gì hoặc cuộn lên đầu trang nếu cần
                  break;
                case 1: // Ví tiền
                  // Giả định có route '/wallets'
                  Navigator.pushReplacementNamed(
                    context,
                    '/wallets',
                    arguments: controller.currentUser,
                  );
                  break;
                case 2: // Nút thêm (thường là một hành động, không phải chuyển màn hình chính)
                  Navigator.pushReplacementNamed(
                    context,
                    '/add_transaction',
                    arguments: controller.currentUser,
                  );
                  break;
                case 3: // Thống kê
                  // Giả định có route '/statistics'
                  Navigator.pushReplacementNamed(
                    context,
                    '/statistics',
                    arguments: controller.currentUser,
                  );
                  break;
                case 4: // Cài đặt
                  Navigator.pushReplacementNamed(
                    context,
                    '/settings',
                    arguments: controller.currentUser,
                  );
                  break;
                default:
                  _showSnackBar('Tính năng này sẽ sớm ra mắt!');
              }
            }
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

  void _showProfileMenu(User? user) {
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
                  backgroundImage:
                      user?.profileImageUrl != null &&
                              user!.profileImageUrl!.isNotEmpty
                          ? NetworkImage(user.profileImageUrl!)
                              as ImageProvider<Object>?
                          : null,
                  child:
                      user?.profileImageUrl == null ||
                              user!.profileImageUrl!.isEmpty
                          ? Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                ),
                SizedBox(height: 15),
                Text(
                  user?.name ?? 'Người dùng',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? 'user@example.com',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ListTile(
                  leading: Icon(Icons.person_outline, color: Color(0xFF5CBDD9)),
                  title: Text('Thông tin cá nhân'),
                  onTap: () async {
                    Navigator.pop(context); // Đóng bottom sheet
                    // Đảm bảo ProfileScreen nhận được đối tượng User
                    final updatedUser = await Navigator.pushNamed(
                      context,
                      '/profile',
                      arguments: user, // Truyền đối tượng User
                    );
                    // Nếu ProfileScreen trả về User đã cập nhật, cập nhật lại trong HomeController
                    if (updatedUser != null && updatedUser is User) {
                      Provider.of<HomeController>(
                        context,
                        listen: false,
                      ).updateCurrentUser(updatedUser);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF5CBDD9),
                  ),
                  title: Text('Cài đặt'),
                  onTap: () {
                    Navigator.pop(context); // Đóng bottom sheet
                    Navigator.pushReplacementNamed(
                      context,
                      '/settings',
                      arguments: user,
                    );
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
                    '/signin', // Quay lại màn hình đăng nhập
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final expensePoints = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width, size.height * 0.2),
    ];

    final incomePoints = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.45, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width, size.height * 0.3),
    ];

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

    paint.style = PaintingStyle.fill;

    paint.color = Colors.pink;
    for (final point in expensePoints) {
      canvas.drawCircle(point, 4, paint);
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

    paint.color = Colors.green;
    for (final point in incomePoints) {
      canvas.drawCircle(point, 4, paint);
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
