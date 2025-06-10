import 'package:flutter/material.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:provider/provider.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthController>(context).currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy thông tin người dùng.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử Đăng nhập'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, size: 80, color: Colors.white70),
              const SizedBox(height: 20),
              Text(
                'Chào ${user.name}, đây là lịch sử đăng nhập của bạn.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tính năng đang được phát triển và sẽ sớm ra mắt.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
