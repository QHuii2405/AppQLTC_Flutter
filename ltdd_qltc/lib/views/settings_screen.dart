import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';

// Import các màn hình con
import 'package:ltdd_qltc/views/profile_screen.dart';
import 'package:ltdd_qltc/views/manage_accounts_screen.dart';
import 'package:ltdd_qltc/views/manage_categories_screen.dart';
import 'package:ltdd_qltc/views/change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cài Đặt'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5CBDD9),
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
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            _buildSectionTitle('Tài khoản'),
            _buildCardContainer(
              child: Column(
                children: [
                  _buildUserInfoCard(widget.user),
                  _buildSettingsTile(
                    icon: Icons.edit_outlined,
                    title: 'Chỉnh sửa hồ sơ',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(user: widget.user),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSectionTitle('Quản lý'),
            _buildCardContainer(
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Quản lý ví tiền',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ManageAccountsScreen(user: widget.user),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.category_outlined,
                    title: 'Quản lý danh mục',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ManageCategoriesScreen(user: widget.user),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSectionTitle('Bảo mật'),
            _buildCardContainer(
              child: _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChangePasswordScreen(user: widget.user),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _buildUserInfoCard(User user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.3),
            backgroundImage:
                user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
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
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.white30, height: 1),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout),
        label: const Text('Đăng xuất'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
