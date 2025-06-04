import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/home_controller.dart'; // Hoặc StatisticsController riêng
import 'package:flutter_application_1/models/user.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  User? _loggedInUser;
  int _currentIndex = 3; // Chỉ mục cho màn hình thống kê

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loggedInUser == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
        // Tải dữ liệu thống kê nếu cần
        // Provider.of<HomeController>(context, listen: false).loadStatisticsData(_loggedInUser!.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      // Có thể dùng StatisticsController riêng
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Thống kê thu chi',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Tổng quan'),
                  Card(
                    color: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildStatRow(
                            'Tổng thu nhập',
                            '0 VND',
                            Colors.greenAccent,
                          ),
                          _buildStatRow(
                            'Tổng chi tiêu',
                            '0 VND',
                            Colors.pinkAccent,
                          ),
                          Divider(color: Colors.white.withOpacity(0.3)),
                          _buildStatRow(
                            'Số dư hiện tại',
                            '0 VND',
                            Colors.lightBlueAccent,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Biểu đồ chi tiêu theo danh mục'),
                  Card(
                    color: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            // Đây là nơi bạn sẽ vẽ biểu đồ tròn (Pie Chart)
                            // Sử dụng CustomPaint hoặc thư viện biểu đồ như fl_chart
                            color: Colors.white.withOpacity(0.1),
                            alignment: Alignment.center,
                            child: const Text(
                              'Biểu đồ tròn sẽ hiển thị ở đây',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Legend cho biểu đồ
                          _buildLegendItem(Colors.blue, 'Ăn uống (30%)'),
                          _buildLegendItem(Colors.red, 'Mua sắm (25%)'),
                          _buildLegendItem(Colors.orange, 'Giải trí (20%)'),
                          _buildLegendItem(Colors.purple, 'Di chuyển (15%)'),
                          _buildLegendItem(Colors.yellow, 'Khác (10%)'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Biểu đồ thu chi theo thời gian'),
                  Card(
                    color: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            // Đây là nơi bạn sẽ vẽ biểu đồ đường (Line Chart) hoặc cột (Bar Chart)
                            color: Colors.white.withOpacity(0.1),
                            alignment: Alignment.center,
                            child: const Text(
                              'Biểu đồ đường/cột sẽ hiển thị ở đây',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Lựa chọn thời gian (Tuần, Tháng, Năm)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Tuần'),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Tháng'),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Năm'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(HomeController controller) {
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
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });

              switch (index) {
                case 0: // Trang chủ
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: _loggedInUser,
                  );
                  break;
                case 1: // Ví tiền
                  Navigator.pushReplacementNamed(
                    context,
                    '/wallets',
                    arguments: _loggedInUser,
                  );
                  break;
                case 2: // Nút thêm (hành động)
                  _showSnackBar('Mở màn hình thêm giao dịch!');
                  // Navigator.pushNamed(context, '/add_transaction', arguments: _loggedInUser);
                  break;
                case 3: // Thống kê (đã ở đây)
                  break;
                case 4: // Cài đặt
                  Navigator.pushReplacementNamed(
                    context,
                    '/settings',
                    arguments: _loggedInUser,
                  );
                  break;
                default:
                  _showSnackBar('Tính năng này sẽ sớm ra mắt!');
              }
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5CBDD9),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 0
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_filled),
              ),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 1
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet),
              ),
              label: 'Ví tiền',
            ),
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
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 3
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pie_chart),
              ),
              label: 'Thống kê',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 4
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings),
              ),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }
}
