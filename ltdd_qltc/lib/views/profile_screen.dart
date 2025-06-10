import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/account.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isEditing = false;

  String? _newImagePath;
  // Biến giữ giá trị ví được chọn (cho Dropdown)
  String? _selectedAccountName;

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.currentUser != null) {
      _updateTextFields(authController.currentUser!);
      Provider.of<AccountController>(context, listen: false)
          .loadAccounts(authController.currentUser!.id!)
          .then((_) {
        // Sau khi tải accounts, nếu có thì chọn cái đầu tiên làm mặc định
        final accountController =
            Provider.of<AccountController>(context, listen: false);
        if (accountController.accounts.isNotEmpty) {
          setState(() {
            _selectedAccountName = accountController.accounts.first.name;
          });
        }
      });
    }
  }

  void _updateTextFields(User user) {
    _nameController.text = user.name;
    _dobController.text = user.dob ?? '';
    _descriptionController.text = user.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(image.path);
      final String savedImagePath = p.join(directory.path, fileName);

      final File imageFile = File(image.path);
      await imageFile.copy(savedImagePath);

      setState(() {
        _newImagePath = savedImagePath;
      });
    }
  }

  Future<void> _saveProfile() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final homeController = Provider.of<HomeController>(context, listen: false);

    if (authController.currentUser == null) {
      _showSnackBar("Không tìm thấy người dùng để cập nhật.");
      return;
    }

    final updatedUser = authController.currentUser!.copyWith(
      name: _nameController.text.trim(),
      dob: _dobController.text.trim(),
      description: _descriptionController.text.trim(),
      profileImageUrl:
          _newImagePath ?? authController.currentUser!.profileImageUrl,
    );

    bool success = await authController.updateUserProfile(updatedUser);

    if (mounted) {
      if (success) {
        homeController.updateCurrentUser(authController.currentUser!);
        setState(() {
          _isEditing = false;
          _newImagePath = null;
        });
        _showSnackBar('Cập nhật hồ sơ thành công!');
      } else {
        _showSnackBar(authController.errorMessage ?? 'Cập nhật thất bại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthController, AccountController>(
      builder: (context, authController, accountController, child) {
        final currentUser = authController.currentUser;
        final List<Account> accounts = accountController.accounts;

        if (currentUser == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: const Center(
              child: Text('Không tìm thấy thông tin người dùng.'),
            ),
          );
        }

        if (!_isEditing) {
          _updateTextFields(currentUser);
        }

        double totalBalance = 0.0;
        for (var account in accounts) {
          totalBalance += account.balance;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Hồ sơ của tôi',
              style: TextStyle(color: Colors.white), // Đảm bảo tiêu đề màu trắng
            ),
            backgroundColor: const Color(0xFF5CBDD9),
            iconTheme:
                const IconThemeData(color: Colors.white), // Icon back màu trắng
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.save_alt_outlined : Icons.edit_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileAvatar(currentUser),
                const SizedBox(height: 16),
                // Tên người dùng - AQuoc
                Center(
                  child: Text(
                    currentUser.name, // Lấy tên người dùng
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Tăng kích thước font cho tên
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tổng số dư và chọn ví
                _buildTotalBalanceCard(totalBalance, accounts),
                const SizedBox(height: 24),
                // Tên của bạn
                _buildProfileTextField(
                  controller: _nameController,
                  labelText: 'Tên của bạn',
                  icon: Icons.person,
                  enabled: _isEditing,
                  initialValue: currentUser.name, // Hiển thị tên hiện tại
                ),
                const SizedBox(height: 16),
                // Ngày sinh
                _buildProfileTextField(
                  controller: _dobController,
                  labelText: 'Ngày sinh (dd/MM/yyyy)',
                  icon: Icons.calendar_today,
                  enabled: _isEditing,
                  readOnly: true,
                  onTap: _isEditing ? () => _selectDate(context) : null,
                ),
                const SizedBox(height: 16),
                // Mô tả về bạn
                _buildProfileTextField(
                  controller: _descriptionController,
                  labelText: 'Mô tả về bạn',
                  icon: Icons.info_outline,
                  enabled: _isEditing,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                // Lịch sử đăng nhập
                _buildLoginHistoryButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(User user) {
    ImageProvider? backgroundImage;
    if (_newImagePath != null) {
      backgroundImage = FileImage(File(_newImagePath!));
    } else if (user.profileImageUrl != null &&
        user.profileImageUrl!.isNotEmpty) {
      backgroundImage = FileImage(File(user.profileImageUrl!));
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white.withOpacity(0.3),
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _pickImage,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(double totalBalance, List<Account> accounts) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng số dư',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                .format(totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Dropdown cho "Tất cả ví"
          DropdownButtonFormField<String>(
            value: _selectedAccountName,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05), // Màu nền mờ hơn
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            dropdownColor: const Color(0xFF4BAFCC).withOpacity(0.9), // Màu nền dropdown
            style: const TextStyle(color: Colors.white, fontSize: 16),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: accounts.map<DropdownMenuItem<String>>((Account account) {
              return DropdownMenuItem<String>(
                value: account.name,
                child: Text(account.name),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedAccountName = newValue;
                // TODO: Cập nhật hiển thị số dư dựa trên ví được chọn nếu cần
              });
            },
            hint: const Text(
              'Tất cả ví',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
    } catch (e) {
      initialDate = DateTime.now();
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5CBDD9), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5CBDD9), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon, // Thêm icon
    bool enabled = false,
    bool readOnly = false,
    int? maxLines = 1,
    VoidCallback? onTap,
    String? initialValue, // Thêm initialValue để set giá trị ban đầu cho controller
  }) {
    // Nếu có initialValue, set nó vào controller khi widget được build lần đầu
    // Hoặc khi enabled chuyển từ false sang true
    if (initialValue != null && controller.text.isEmpty && !enabled) {
      controller.text = initialValue;
    }

    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: enabled ? Colors.white : Colors.white54), // Màu label
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.white.withOpacity(0.7))
            : null, // Icon ở đầu input
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Màu nền mờ
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginHistoryButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Điều hướng đến màn hình lịch sử đăng nhập
        _showSnackBar('Chức năng lịch sử đăng nhập chưa được triển khai.');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.history, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Lịch sử đăng nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}