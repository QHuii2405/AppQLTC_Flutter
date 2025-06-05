import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/theme_provider.dart'; // Mới: Import ThemeProvider

// Import các màn hình sẽ điều hướng đến
import 'package:ltdd_qltc/views/profile_screen.dart';
import 'package:ltdd_qltc/views/manage_accounts_screen.dart';
import 'package:ltdd_qltc/views/manage_categories_screen.dart';
import 'package:ltdd_qltc/views/change_password_screen.dart';
import 'package:ltdd_qltc/views/login_history_screen.dart';


class SettingsScreen extends StatefulWidget {
  final User user; // Đối tượng người dùng hiện tại
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // `_notificationsEnabled` và `_selectedCurrency` sẽ bị xóa vì chức năng đã bị loại bỏ
  // bool _notificationsEnabled = true; // Sẽ bị xóa
  // String _selectedCurrency = 'VND'; // Sẽ bị xóa

  // Trạng thái cục bộ cho chế độ tối, sẽ được đồng bộ với ThemeProvider
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái _darkModeEnabled dựa trên ThemeProvider hiện tại
    _darkModeEnabled = Provider.of<ThemeProvider>(context, listen: false).themeMode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe ThemeProvider để cập nhật UI nếu theme thay đổi từ bên ngoài
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        _darkModeEnabled = themeProvider.themeMode == ThemeMode.dark; // Đồng bộ trạng thái

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Cài Đặt',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            // backgroundColor: const Color(0xFF5CBDD9), // Được kiểm soát bởi MaterialApp theme
            // iconTheme: const IconThemeData(color: Colors.white), // Được kiểm soát bởi MaterialApp theme
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // Màu gradient sẽ thay đổi tùy thuộc vào themeMode của MaterialApp
                // Bạn có thể giữ gradient cố định hoặc tạo 2 set màu cho light/dark theme
                // Hiện tại, giữ cố định để phù hợp với hình ảnh bạn cung cấp cho màn hình login
                colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần thông tin người dùng
                  _buildSectionTitle('Tài khoản', Icons.person_outline),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        _buildUserInfoCard(widget.user),
                        _buildSettingsTile(
                          icon: Icons.edit_outlined,
                          title: 'Chỉnh sửa hồ sơ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(user: widget.user),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cài đặt quản lý
                  _buildSectionTitle('Quản lý', Icons.settings_outlined),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Quản lý ví tiền',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageAccountsScreen(user: widget.user),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsTile(
                          icon: Icons.category_outlined,
                          title: 'Quản lý danh mục',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageCategoriesScreen(user: widget.user),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tùy chỉnh ứng dụng (Chỉ còn Chế độ tối)
                  _buildSectionTitle('Tùy chỉnh', Icons.apps_outlined),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        _buildSwitchSettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: 'Chế độ tối',
                          value: _darkModeEnabled,
                          onChanged: (bool value) {
                            // Cập nhật trạng thái trong ThemeProvider
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
                            // Cập nhật trạng thái cục bộ để UI thay đổi ngay lập tức
                            setState(() {
                              _darkModeEnabled = value;
                            });
                            _showSnackBar(value ? 'Chế độ tối đã bật' : 'Chế độ tối đã tắt');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bảo mật
                  _buildSectionTitle('Bảo mật', Icons.security),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          icon: Icons.lock_outline,
                          title: 'Đổi mật khẩu',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordScreen(user: widget.user),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsTile(
                          icon: Icons.history,
                          title: 'Lịch sử đăng nhập',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginHistoryScreen(user: widget.user),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Về ứng dụng (Hỗ trợ đã bị xóa)
                  _buildSectionTitle('Thông tin khác', Icons.info_outline),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        // _buildSettingsTile đã xóa
                        // _buildDivider() đã xóa
                        _buildSettingsTile(
                          icon: Icons.info_outline,
                          title: 'Về ứng dụng',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'EWallet',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2023 EWallet. All rights reserved.',
                              children: [
                                const Text('Ứng dụng quản lý thu chi giúp bạn theo dõi tài chính cá nhân một cách hiệu quả.'),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nút Đăng xuất
                  _buildLogoutButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget tiêu đề phần với icon
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget chứa các mục cài đặt bên trong Card
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // Widget thẻ thông tin người dùng
  Widget _buildUserInfoCard(User user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.3),
            backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho một tùy chọn cài đặt
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  // Widget cho tùy chọn cài đặt dạng Switch
  Widget _buildSwitchSettingsTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.lightGreenAccent,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  // Widget Divider tùy chỉnh
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        color: Colors.white30,
        height: 1,
        thickness: 0.5,
      ),
    );
  }

  // Nút đăng xuất
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () => _confirmLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 5,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 24),
            SizedBox(width: 10),
            Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog xác nhận đăng xuất
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthController>(context, listen: false).signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
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
