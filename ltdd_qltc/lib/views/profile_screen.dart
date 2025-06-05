import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Để định dạng số tiền
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/account.dart'; // Import model Account
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart'; // Import AccountController
import 'package:ltdd_qltc/controllers/home_controller.dart'; // Import HomeController để làm mới tổng số dư trên Home

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser; // Lưu trữ đối tượng User hiện tại, có thể được cập nhật
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isEditing = false; // Trạng thái chỉnh sửa
  Account? _selectedWallet; // Ví được chọn để hiển thị số dư, null = tổng số dư
  double _displayedBalance = 0.0; // Số dư đang hiển thị
  List<Account> _userWallets = []; // Danh sách tất cả ví của người dùng

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // Khởi tạo người dùng hiện tại
    _nameController.text = _currentUser?.name ?? '';
    _dobController.text = _currentUser?.dob ?? '';
    _descriptionController.text = _currentUser?.description ?? '';

    // Tải danh sách ví và thiết lập lắng nghe
    final accountController = Provider.of<AccountController>(
      context,
      listen: false,
    );
    _userWallets = accountController.accounts; // Lấy danh sách ví ban đầu
    accountController.addListener(_onAccountsChanged); // Lắng nghe thay đổi

    // Tính toán số dư ban đầu
    _updateDisplayedBalance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đảm bảo user của AuthController được cập nhật (nếu có thay đổi từ màn hình khác)
    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.currentUser != null &&
        _currentUser != authController.currentUser) {
      setState(() {
        _currentUser = authController.currentUser;
        _nameController.text = _currentUser?.name ?? '';
        _dobController.text = _currentUser?.dob ?? '';
        _descriptionController.text = _currentUser?.description ?? '';
      });
    }
  }

  // Lắng nghe thay đổi của AccountController để cập nhật danh sách ví và số dư
  void _onAccountsChanged() {
    setState(() {
      _userWallets = Provider.of<AccountController>(
        context,
        listen: false,
      ).accounts;
      _updateDisplayedBalance(); // Cập nhật lại số dư hiển thị
    });
  }

  // Phương thức tính toán và cập nhật số dư hiển thị
  void _updateDisplayedBalance() {
    if (_selectedWallet == null) {
      // Tính tổng số dư của tất cả các ví
      _displayedBalance = _userWallets.fold(
        0.0,
        (sum, account) => sum + account.balance,
      );
    } else {
      // Hiển thị số dư của ví được chọn
      // Cần tìm lại ví từ danh sách hiện tại để đảm bảo số dư là mới nhất
      final selectedAcc = _userWallets.firstWhere(
        (acc) => acc.id == _selectedWallet!.id,
        orElse: () => _selectedWallet!,
      );
      _displayedBalance = selectedAcc.balance;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _descriptionController.dispose();
    Provider.of<AccountController>(
      context,
      listen: false,
    ).removeListener(_onAccountsChanged);
    super.dispose();
  }

  // Phương thức chuyển đổi giữa chế độ chỉnh sửa và lưu
  void _toggleEditSave() async {
    if (_isEditing) {
      // Đang ở chế độ chỉnh sửa, nhấn nút này để lưu
      await _saveProfile();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Phương thức lưu thông tin hồ sơ
  Future<void> _saveProfile() async {
    if (_currentUser == null) {
      _showSnackBar('Lỗi: Không tìm thấy thông tin người dùng.');
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);

    // Tạo một đối tượng User mới với các thông tin đã chỉnh sửa
    final updatedUser = _currentUser!.copyWith(
      name: _nameController.text.trim(),
      dob: _dobController.text.trim().isNotEmpty
          ? _dobController.text.trim()
          : null,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    bool success = await authController.updateUserProfile(
      updatedUser,
    ); // Gọi phương thức update mới

    if (success) {
      _showSnackBar('Cập nhật hồ sơ thành công!');
      // Cập nhật lại _currentUser trong state của ProfileScreen
      setState(() {
        _currentUser = updatedUser;
      });
      // Làm mới dữ liệu trang chủ (tên người dùng trên AppBar)
      Provider.of<HomeController>(
        context,
        listen: false,
      ).loadHomeData(_currentUser!.id!);
    } else {
      _showSnackBar(authController.errorMessage ?? 'Cập nhật hồ sơ thất bại.');
    }
  }

  // Hàm hiển thị DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat(
        'dd/MM/yyyy',
      ).parse(_dobController.text.isEmpty ? '01/01/2000' : _dobController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale(
        'vi',
        'VN',
      ), // Cần có localizationsDelegates trong MaterialApp
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5CBDD9), // Màu chủ đạo của DatePicker
              onPrimary: Colors.white, // Màu chữ trên primary
              surface: Colors.white, // Màu nền DatePicker
              onSurface: Colors.black87, // Màu chữ trên nền
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hồ sơ của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5CBDD9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditSave,
          ),
          const SizedBox(width: 8),
        ],
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thông tin người dùng (ảnh đại diện, email)
              _buildProfileHeader(),
              const SizedBox(height: 20),

              // Tổng số dư và chọn ví
              _buildBalanceCard(),
              const SizedBox(height: 20),

              // Các trường thông tin có thể chỉnh sửa
              _buildEditableProfileFields(),
              const SizedBox(height: 20),

              // Các mục cài đặt khác (Chỉ còn Lịch sử đăng nhập)
              _buildOtherSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage:
              _currentUser?.profileImageUrl != null &&
                  _currentUser!.profileImageUrl!.isNotEmpty
              ? NetworkImage(_currentUser!.profileImageUrl!)
              : null,
          child:
              _currentUser?.profileImageUrl == null ||
                  _currentUser!.profileImageUrl!.isEmpty
              ? const Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 15),
        Text(
          _currentUser?.email ?? 'N/A',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedWallet == null
                ? 'Tổng số dư'
                : 'Số dư ví: ${_selectedWallet!.name}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'VND',
            ).format(_displayedBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          // Dropdown để chọn ví
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Account?>(
                value: _selectedWallet,
                hint: Text(
                  'Chọn ví để xem số dư',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                dropdownColor: const Color(0xFF4BAFCC),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                isExpanded: true,
                onChanged: (Account? newValue) {
                  setState(() {
                    _selectedWallet = newValue;
                    _updateDisplayedBalance(); // Cập nhật số dư hiển thị
                  });
                },
                items: [
                  DropdownMenuItem<Account?>(
                    value: null, // Giá trị null cho "Tổng số dư"
                    child: Text(
                      'Tất cả ví',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ..._userWallets.map<DropdownMenuItem<Account>>((
                    Account account,
                  ) {
                    return DropdownMenuItem<Account>(
                      value: account,
                      child: Text(
                        account.name,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileFields() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        children: [
          _buildProfileTextField(
            controller: _nameController,
            labelText: 'Tên của bạn',
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),
          const SizedBox(height: 15),
          _buildDatePickerField(
            controller: _dobController,
            labelText: 'Ngày sinh (dd/MM/yyyy)',
            icon: Icons.calendar_today_outlined,
            enabled: _isEditing,
            onTap: _isEditing
                ? () => _selectDate(context)
                : null, // Chỉ cho phép chọn khi chỉnh sửa
          ),
          const SizedBox(height: 15),
          _buildProfileTextField(
            controller: _descriptionController,
            labelText: 'Mô tả về bạn',
            icon: Icons.info_outline,
            enabled: _isEditing,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = false,
    int? maxLines,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: enabled ? Colors.white70 : Colors.white54),
        prefixIcon: Icon(
          icon,
          color: enabled ? Colors.white70 : Colors.white54,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        // Ngăn không cho TextField nhận focus khi không enabled
        absorbing: !enabled,
        child: TextField(
          controller: controller,
          enabled: enabled,
          readOnly: true, // Luôn chỉ đọc để mở DatePicker qua onTap
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: enabled ? Colors.white70 : Colors.white54,
            ),
            prefixIcon: Icon(
              icon,
              color: enabled ? Colors.white70 : Colors.white54,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherSettings() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        children: [
          // Đã xóa: Mục "Đổi mật khẩu"
          // _buildSettingsTile(
          //   icon: Icons.lock_outline,
          //   title: 'Đổi mật khẩu',
          //   onTap: () {
          //     // Navigator.pushNamed(context, '/change_password', arguments: _currentUser);
          //   },
          // ),
          // const Divider(color: Colors.white30, height: 1, thickness: 0.5, indent: 16, endIndent: 16), // Xóa divider tương ứng
          _buildSettingsTile(
            icon: Icons.history,
            title: 'Lịch sử đăng nhập',
            onTap: () {
              Navigator.pushNamed(
                context,
                '/login_history',
                arguments: _currentUser,
              );
            },
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
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
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
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return; // Kiểm tra mounted trước khi show SnackBar
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
