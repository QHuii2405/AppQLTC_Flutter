import 'package:flutter/material.dart';
import 'package:ltdd_qltc/models/user.dart'; // Import User model

class StatisticsScreen extends StatelessWidget {
  final User user; // Nhận đối tượng User
  const StatisticsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Chi Tiêu'),
        backgroundColor: const Color(0xFF5CBDD9),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Chào ${user.name}, đây là màn hình thống kê của bạn.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Biểu đồ và báo cáo chi tiêu của bạn sẽ xuất hiện ở đây.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
