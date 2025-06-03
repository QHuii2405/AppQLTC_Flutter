import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/database_helper.dart'; // Import DatabaseHelper
import 'package:intl/intl.dart'; // Để định dạng ngày tháng

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _loggedInUser;
  bool _isEditingProfile = false; // Trạng thái chỉnh sửa hồ sơ

  // Controllers cho các trường thông tin người dùng
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(); // Ngày sinh
  final TextEditingController _descriptionController =
      TextEditingController(); // Mô tả bản thân
  String? _tempProfileImageUrl; // Để giữ URL ảnh mới tạm thời

  @override
  void initState() {
    super.initState();
    // Các controller sẽ được điền dữ liệu trong didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy thông tin người dùng từ arguments khi màn hình được khởi tạo
    if (_loggedInUser == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
        // Điền dữ liệu vào các controller
        _nameController.text = _loggedInUser!.name;
        _emailController.text = _loggedInUser!.email;
        _dobController.text =
            _loggedInUser!.dob ?? ''; // Giả định User model có trường dob
        _descriptionController.text =
            _loggedInUser!.description ??
            ''; // Giả định User model có trường description
        _tempProfileImageUrl = _loggedInUser!.profileImageUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tài khoản của tôi',
          style: TextStyle(color: Colors.white),
        ),
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
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF5CBDD9),
                  backgroundImage:
                      _tempProfileImageUrl != null &&
                              _tempProfileImageUrl!.isNotEmpty
                          ? NetworkImage(_tempProfileImageUrl!)
                              as ImageProvider<Object>?
                          : null,
                  child:
                      _tempProfileImageUrl == null ||
                              _tempProfileImageUrl!.isEmpty
                          ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right:
                      MediaQuery.of(context).size.width / 2 -
                      60 +
                      40, // Điều chỉnh vị trí camera icon
                  child: GestureDetector(
                    onTap:
                        _isEditingProfile
                            ? _pickImage
                            : null, // Chỉ cho phép chọn ảnh khi đang chỉnh sửa
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF5CBDD9),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Thu nhập, Chi tiêu, Số dư (hiện tại là placeholder)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Thu nhập', '0 VND', Colors.greenAccent),
                _buildStatColumn('Chi tiêu', '0 VND', Colors.pinkAccent),
                _buildStatColumn('Số dư', '0 VND', Colors.lightBlueAccent),
              ],
            ),
            const SizedBox(height: 30),
            _buildProfileTextField(
              _nameController,
              'Tên',
              Icons.person_outline,
              _isEditingProfile,
            ),
            const SizedBox(height: 15),
            _buildProfileTextField(
              _emailController,
              'Email',
              Icons.email_outlined,
              false,
            ), // Email không chỉnh sửa
            const SizedBox(height: 15),
            _buildProfileTextField(
              _dobController,
              'Ngày sinh',
              Icons.calendar_today_outlined,
              _isEditingProfile,
              onTap: _isEditingProfile ? _selectDate : null,
            ),
            const SizedBox(height: 15),
            _buildProfileTextField(
              _descriptionController,
              'Mô tả bản thân',
              Icons.description_outlined,
              _isEditingProfile,
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            if (_isEditingProfile) // Nút lưu chỉ hiện khi đang chỉnh sửa
              ElevatedButton(
                onPressed: _saveProfileChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Lưu thay đổi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditingProfile = !_isEditingProfile;
                  // Nếu hủy chỉnh sửa, đặt lại dữ liệu từ _loggedInUser
                  if (!_isEditingProfile && _loggedInUser != null) {
                    _nameController.text = _loggedInUser!.name;
                    _emailController.text = _loggedInUser!.email;
                    _dobController.text = _loggedInUser!.dob ?? '';
                    _descriptionController.text =
                        _loggedInUser!.description ?? '';
                    _tempProfileImageUrl = _loggedInUser!.profileImageUrl;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isEditingProfile ? Colors.grey : const Color(0xFF5CBDD9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _isEditingProfile ? 'Hủy chỉnh sửa' : 'Chỉnh sửa thông tin',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Phần Bạn bè
            _buildSectionTitle('Bạn bè'),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orange,
                  child: Text(
                    'A',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 15),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.purple,
                  child: Text(
                    'B',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 15),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.teal,
                  child: Text(
                    'C',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '+5',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool editable, {
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: !editable,
      maxLines: maxLines,
      onTap: onTap, // Thêm onTap cho trường ngày sinh
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          // Style cho trường readOnly
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF5CBDD9), // Màu chính của date picker
            colorScheme: const ColorScheme.light(primary: Color(0xFF5CBDD9)),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
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

  void _pickImage() {
    _showSnackBar('Tính năng chọn ảnh sẽ sớm ra mắt');
    // Giả lập việc chọn ảnh
    setState(() {
      _tempProfileImageUrl =
          'https://placehold.co/100x100/FF0000/FFFFFF?text=New+Img'; // Placeholder cho ảnh mới
    });
  }

  void _saveProfileChanges() {
    // Logic lưu thay đổi vào database
    _showSnackBar('Lưu thay đổi hồ sơ');
    setState(() {
      _isEditingProfile = false; // Thoát chế độ chỉnh sửa sau khi lưu
      // Cập nhật _loggedInUser với dữ liệu mới từ các controller
      if (_loggedInUser != null) {
        _loggedInUser!.name = _nameController.text;
        _loggedInUser!.profileImageUrl = _tempProfileImageUrl;
        _loggedInUser!.dob =
            _dobController.text; // Cần thêm trường dob vào User model
        _loggedInUser!.description =
            _descriptionController
                .text; // Cần thêm trường description vào User model
        // Gọi DatabaseHelper để cập nhật người dùng trong DB tại đây
        // DatabaseHelper().updateUser(_loggedInUser!);
      }
    });
    Navigator.pop(context, _loggedInUser); // Trả về người dùng đã cập nhật
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }
}
