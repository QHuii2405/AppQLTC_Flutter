import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/home_controller.dart';
import 'package:flutter_application_1/controllers/settings_controller.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:provider/provider.dart'; // Import Provider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4; // Đặt chỉ mục hiện tại là 4 (Cài đặt)
  User? _loggedInUser; // Lưu trữ đối tượng User đã đăng nhập

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy dữ liệu người dùng từ arguments
    if (_loggedInUser == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ SettingsController (nếu có logic động)
    return Consumer<SettingsController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Cài đặt', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF5CBDD9),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
              ),
            ),
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.person_outline,
                            color: Color(0xFF5CBDD9),
                          ),
                          title: Text(
                            'Thông tin cá nhân',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            // Điều hướng đến ProfileScreen và truyền đối tượng User
                            final updatedUser = await Navigator.pushNamed(
                              context,
                              '/profile',
                              arguments: _loggedInUser,
                            );
                            // Nếu ProfileScreen trả về User đã cập nhật, cập nhật lại trong HomeScreen Controller
                            // (Vì HomeScreen là nơi quản lý User chính)
                            if (updatedUser != null && updatedUser is User) {
                              Provider.of<HomeController>(
                                context,
                                listen: false,
                              ).updateCurrentUser(updatedUser);
                              // Cập nhật lại _loggedInUser trong SettingsScreen nếu cần
                              setState(() {
                                _loggedInUser = updatedUser;
                              });
                            }
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.security,
                            color: Color(0xFF5CBDD9),
                          ),
                          title: Text(
                            'Bảo mật tài khoản',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showSnackBar(
                              context,
                              'Tính năng bảo mật tài khoản sẽ sớm ra mắt',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.notifications_none,
                            color: Color(0xFF5CBDD9),
                          ),
                          title: Text(
                            'Thông báo',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showSnackBar(
                              context,
                              'Tính năng thông báo sẽ sớm ra mắt',
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.language,
                            color: Color(0xFF5CBDD9),
                          ),
                          title: Text(
                            'Ngôn ngữ',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showSnackBar(
                              context,
                              'Tính năng ngôn ngữ sẽ sớm ra mắt',
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.color_lens_outlined,
                            color: Color(0xFF5CBDD9),
                          ),
                          title: Text(
                            'Chủ đề',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showSnackBar(
                              context,
                              'Tính năng chủ đề sẽ sớm ra mắt',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.help_outline,
                            color: Color(0xFF5CBDD9),
                          ),
                          title: Text(
                            'Trợ giúp & Hỗ trợ',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showSnackBar(
                              context,
                              'Tính năng trợ giúp sẽ sớm ra mắt',
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: Color(0xFF5CBDD9),
                          ),
                          title: Text(
                            'Về ứng dụng',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showSnackBar(
                              context,
                              'Thông tin về ứng dụng sẽ sớm ra mắt',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(
            _loggedInUser,
          ), // Truyền user vào bottom nav
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(User? user) {
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
                case 0: // Trang chủ
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: user,
                  );
                  break;
                case 1: // Ví tiền
                  Navigator.pushReplacementNamed(
                    context,
                    '/wallets',
                    arguments: user,
                  );
                  break;
                case 2: // Nút thêm
                  _showSnackBar(context, 'Mở màn hình thêm giao dịch!');
                  break;
                case 3: // Thống kê
                  Navigator.pushReplacementNamed(
                    context,
                    '/statistics',
                    arguments: user,
                  );
                  break;
                case 4: // Cài đặt (đã ở đây)
                  // Không làm gì
                  break;
                default:
                  _showSnackBar(context, 'Tính năng này sẽ sớm ra mắt!');
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy', style: TextStyle(color: Color(0xFF5CBDD9))),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signin',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
