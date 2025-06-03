import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart'; // Cần import User model
import 'package:intl/intl.dart'; // Import để định dạng ngày tháng nếu cần (cho currentTime trong StatusBar)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User?
  _loggedInUser; // Để lưu trữ thông tin người dùng nếu được truyền qua arguments
  bool _notificationsEnabled = true; // Trạng thái thông báo được quản lý cục bộ
  int _currentIndex = 4; // Đặt chỉ mục hiện tại là 4 cho màn hình Cài đặt

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy thông tin người dùng từ arguments khi màn hình được khởi tạo
    if (_loggedInUser == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5CBDD9),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Đặt màu icon back
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Phần Thông tin người dùng
            _buildSectionTitle('Thông tin cá nhân'),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () {
                // Điều hướng đến ProfileScreen và truyền đối tượng User
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: _loggedInUser,
                );
              },
            ),

            // Phần Bảo mật tài khoản
            _buildSectionTitle('Bảo mật tài khoản'),
            _buildSettingItem(
              icon: Icons.security,
              title: 'Bảo mật tài khoản',
              onTap: () {
                // Điều hướng đến SecuritySettingsScreen và truyền đối tượng User
                Navigator.pushNamed(
                  context,
                  '/security_settings',
                  arguments: _loggedInUser,
                );
              },
            ),

            const SizedBox(height: 20),

            // Phần Cài đặt ứng dụng
            _buildSectionTitle('Cài đặt ứng dụng'),
            SwitchListTile(
              secondary: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'Thông báo',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              value: _notificationsEnabled, // Lấy trạng thái cục bộ
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value; // Cập nhật trạng thái cục bộ
                });
                _showSnackBar('Thông báo đã ${value ? 'bật' : 'tắt'}');
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.greenAccent,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
            _buildSettingItem(
              icon: Icons.group_outlined, // Icon mới cho "Bạn bè"
              title: 'Bạn bè', // Đã đổi tên
              onTap: () {
                _showSnackBar('Mở danh sách bạn bè');
              },
            ),
            _buildSettingItem(
              icon: Icons.category_outlined, // Icon mới cho "Thể loại"
              title: 'Thể loại', // Đã đổi tên
              onTap: () {
                _showSnackBar('Mở quản lý thể loại');
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Khác'),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Trợ giúp & Hỗ trợ',
              onTap: () {
                _showSnackBar('Mở thông tin trợ giúp');
              },
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'Về ứng dụng',
              onTap: () {
                _showSnackBar('Mở thông tin về ứng dụng');
              },
            ),
            _buildSettingItem(
              icon: Icons.star_border,
              title: 'Đánh giá ứng dụng',
              onTap: () {
                _showSnackBar('Mở cửa hàng ứng dụng để đánh giá');
              },
            ),
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              color: Colors.red,
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(), // Thêm BottomNavigationBar
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontSize: 16)),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle,
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 14),
                )
                : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: onTap,
      ),
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
                  // Hoặc Navigator.pushNamed(context, '/add_transaction');
                  break;
                case 3: // Thống kê
                  Navigator.pushReplacementNamed(
                    context,
                    '/statistics',
                    arguments: _loggedInUser,
                  );
                  break;
                case 4: // Cài đặt (đã ở đây)
                  // Không làm gì hoặc cuộn lên đầu trang nếu cần
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

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin', // Quay lại màn hình đăng nhập
                    (route) => false,
                  );
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
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
