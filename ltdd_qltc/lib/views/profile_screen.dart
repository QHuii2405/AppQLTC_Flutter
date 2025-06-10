import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _nameController.text = _currentUser.name;
    _dobController.text = _currentUser.dob ?? '';
    _descriptionController.text = _currentUser.description ?? '';
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

  Future<void> _saveProfile() async {
    final updatedUser = _currentUser.copyWith(
      name: _nameController.text.trim(),
      dob: _dobController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    final authController = Provider.of<AuthController>(context, listen: false);
    bool success = await authController.updateUserProfile(updatedUser);

    if (mounted) {
      if (success) {
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
        });
        Provider.of<HomeController>(
          context,
          listen: false,
        ).updateCurrentUser(updatedUser);
        _showSnackBar('Cập nhật hồ sơ thành công!');
      } else {
        _showSnackBar(authController.errorMessage ?? 'Cập nhật thất bại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        backgroundColor: const Color(0xFF5CBDD9),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
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
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage:
                        _currentUser.profileImageUrl != null &&
                            _currentUser.profileImageUrl!.isNotEmpty
                        ? NetworkImage(_currentUser.profileImageUrl!)
                        : null,
                    child:
                        _currentUser.profileImageUrl == null ||
                            _currentUser.profileImageUrl!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
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
                          onPressed: () {
                            // Logic to change profile picture
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
              onTap: _isEditing
                  ? () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(
                              _dobController.text.split('/').reversed.join('-'),
                            ) ??
                            DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _dobController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(picked);
                      }
                    }
                  : null,
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
      ),
    );
  }
}
