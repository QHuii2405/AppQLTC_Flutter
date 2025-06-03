import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/profile_controller.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:provider/provider.dart'; // Import Provider

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;

  User? _currentUser; // Đối tượng User từ Model
  bool _isEditingPassword = false;
  String? _profileImageUrl; // Đường dẫn ảnh đại diện

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy đối tượng User được truyền qua arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is User) {
      _currentUser = args;
      _nameController.text = _currentUser?.name ?? '';
      _profileImageUrl = _currentUser?.profileImageUrl;
      // Cập nhật người dùng hiện tại trong controller
      Provider.of<ProfileController>(
        context,
        listen: false,
      ).setCurrentUser(_currentUser!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.black87}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_currentUser == null || _currentUser!.id == null) {
      _showSnackBar(
        'Không thể lưu thay đổi: Không tìm thấy ID người dùng.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final profileController = Provider.of<ProfileController>(
      context,
      listen: false,
    );
    bool changesMade = false;

    // Kiểm tra và cập nhật tên
    if (_nameController.text.trim() != (_currentUser?.name ?? '')) {
      changesMade = true;
    }

    // Kiểm tra và cập nhật ảnh đại diện (giả định _profileImageUrl đã được cập nhật từ bộ chọn ảnh)
    if (_profileImageUrl != (_currentUser?.profileImageUrl)) {
      changesMade = true;
    }

    // Kiểm tra và xử lý thay đổi mật khẩu
    bool passwordChanged = false;
    if (_isEditingPassword) {
      if (_oldPasswordController.text.isEmpty ||
          _newPasswordController.text.isEmpty ||
          _confirmNewPasswordController.text.isEmpty) {
        _showSnackBar(
          'Vui lòng điền đầy đủ các trường mật khẩu.',
          backgroundColor: Colors.orange,
        );
        return;
      }

      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        _showSnackBar(
          'Mật khẩu mới và xác nhận mật khẩu không khớp.',
          backgroundColor: Colors.red,
        );
        return;
      }
      passwordChanged = true;
      changesMade = true;
    }

    if (!changesMade) {
      _showSnackBar('Không có thay đổi nào để lưu.');
      return;
    }

    bool success = await profileController.saveProfileChanges(
      userId: _currentUser!.id!,
      newName: _nameController.text.trim(),
      oldPassword: passwordChanged ? _oldPasswordController.text : null,
      newPassword: passwordChanged ? _newPasswordController.text : null,
      profileImageUrl: _profileImageUrl,
    );

    if (success) {
      _showSnackBar('Đã lưu thay đổi thành công!');
      // Cập nhật lại UI sau khi lưu thành công
      setState(() {
        if (passwordChanged) {
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
          _isEditingPassword = false;
        }
      });
      // Trả về User đã cập nhật cho màn hình gọi đến (SettingsScreen)
      Navigator.pop(context, profileController.currentUser);
    } else {
      _showSnackBar(
        'Lưu thay đổi thất bại. Vui lòng kiểm tra mật khẩu cũ hoặc thử lại.',
        backgroundColor: Colors.red,
      );
    }
  }

  void _changeProfilePicture() {
    // Đây là nơi bạn sẽ tích hợp thư viện image_picker.
    // Ví dụ:
    // final ImagePicker _picker = ImagePicker();
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   // Tải ảnh lên dịch vụ lưu trữ (ví dụ: Firebase Storage)
    //   // Lấy URL của ảnh sau khi tải lên
    //   String newImageUrl = 'URL_CUA_ANH_VUA_TAI_LEN';
    //   setState(() {
    //     _profileImageUrl = newImageUrl;
    //   });
    //   _showSnackBar('Ảnh đại diện đã được chọn. Nhấn "Lưu thay đổi" để cập nhật.');
    // } else {
    //   _showSnackBar('Không có ảnh nào được chọn.');
    // }

    _showSnackBar('Tính năng thay đổi ảnh đại diện sẽ sớm ra mắt!');
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ ProfileController
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        // Cập nhật _currentUser từ controller nếu có thay đổi từ bên ngoài (ví dụ: sau khi saveChanges)
        if (controller.currentUser != null &&
            _currentUser != controller.currentUser) {
          _currentUser = controller.currentUser;
          _nameController.text = _currentUser?.name ?? '';
          _profileImageUrl = _currentUser?.profileImageUrl;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Thông tin cá nhân',
              style: TextStyle(color: Colors.white),
            ),
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
            child:
                controller.isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.3,
                                    ),
                                    backgroundImage:
                                        _profileImageUrl != null &&
                                                _profileImageUrl!.isNotEmpty
                                            ? NetworkImage(_profileImageUrl!)
                                                as ImageProvider<Object>?
                                            : null,
                                    child:
                                        _profileImageUrl == null ||
                                                _profileImageUrl!.isEmpty
                                            ? Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4BAFCC),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          Card(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Tên của bạn',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Color(0xFF5CBDD9),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),

                          Card(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text:
                                      _currentUser?.email ??
                                      'email@example.com',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Color(0xFF5CBDD9),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingPassword = !_isEditingPassword;
                                  if (!_isEditingPassword) {
                                    _oldPasswordController.clear();
                                    _newPasswordController.clear();
                                    _confirmNewPasswordController.clear();
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isEditingPassword
                                        ? Colors.grey
                                        : Color(0xFF5CBDD9),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                _isEditingPassword
                                    ? 'Hủy thay đổi mật khẩu'
                                    : 'Thay đổi mật khẩu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          Visibility(
                            visible: _isEditingPassword,
                            child: Column(
                              children: [
                                Card(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: TextField(
                                      controller: _oldPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Mật khẩu cũ',
                                        labelStyle: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Color(0xFF5CBDD9),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Card(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: TextField(
                                      controller: _newPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Mật khẩu mới',
                                        labelStyle: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Color(0xFF5CBDD9),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Card(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: TextField(
                                      controller: _confirmNewPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Xác nhận mật khẩu mới',
                                        labelStyle: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Color(0xFF5CBDD9),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),

                          ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4BAFCC),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
          ),
        );
      },
    );
  }
}
