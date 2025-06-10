import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';

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

  // Biến để lưu đường dẫn ảnh mới (nếu có)
  String? _newImagePath;

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.currentUser != null) {
      _updateTextFields(authController.currentUser!);
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

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Chọn ảnh từ thư viện
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Lấy thư mục để lưu trữ file
      final directory = await getApplicationDocumentsDirectory();
      // Tạo một tên file duy nhất
      final String fileName = p.basename(image.path);
      final String savedImagePath = p.join(directory.path, fileName);

      // Sao chép file ảnh đã chọn vào thư mục của ứng dụng
      final File imageFile = File(image.path);
      await imageFile.copy(savedImagePath);

      // Lưu đường dẫn ảnh mới vào state để hiển thị tạm thời
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
      // Cập nhật đường dẫn ảnh mới nếu có
      profileImageUrl:
          _newImagePath ?? authController.currentUser!.profileImageUrl,
    );

    bool success = await authController.updateUserProfile(updatedUser);

    if (mounted) {
      if (success) {
        homeController.updateCurrentUser(authController.currentUser!);
        setState(() {
          _isEditing = false;
          _newImagePath = null; // Reset sau khi lưu thành công
        });
        _showSnackBar('Cập nhật hồ sơ thành công!');
      } else {
        _showSnackBar(authController.errorMessage ?? 'Cập nhật thất bại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final currentUser = authController.currentUser;

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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ của tôi'),
            backgroundColor: const Color(0xFF5CBDD9),
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.save_alt_outlined : Icons.edit_outlined,
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
                const SizedBox(height: 24),
                _buildProfileTextField(
                  controller: _nameController,
                  labelText: 'Tên hiển thị',
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                _buildProfileTextField(
                  controller: _dobController,
                  labelText: 'Ngày sinh (dd/MM/yyyy)',
                  enabled: _isEditing,
                  readOnly: true,
                  onTap: _isEditing ? () => _selectDate(context) : null,
                ),
                const SizedBox(height: 16),
                _buildProfileTextField(
                  controller: _descriptionController,
                  labelText: 'Mô tả',
                  enabled: _isEditing,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(User user) {
    // Xác định ảnh để hiển thị: ảnh mới > ảnh cũ > icon mặc định
    ImageProvider? backgroundImage;
    if (_newImagePath != null) {
      backgroundImage = FileImage(File(_newImagePath!));
    } else if (user.profileImageUrl != null &&
        user.profileImageUrl!.isNotEmpty) {
      // Giả sử đường dẫn lưu trong DB là đường dẫn file cục bộ
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
                  onPressed: _pickImage, // Gọi hàm chọn ảnh
                ),
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
    );
    if (picked != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String labelText,
    bool enabled = false,
    bool readOnly = false,
    int? maxLines = 1,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: enabled ? Colors.white : Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
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
}
