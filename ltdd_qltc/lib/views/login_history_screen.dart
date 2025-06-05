import 'package:flutter/material.dart';
import 'package:ltdd_qltc/models/user.dart'; // Import User model

class LoginHistoryScreen extends StatelessWidget {
  final User user; // Nhận đối tượng User
  const LoginHistoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch sử Đăng nhập',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5CBDD9),
        foregroundColor: Colors.white,
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
                'Tính năng hiển thị chi tiết lịch sử đăng nhập sẽ sớm ra mắt.',
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
