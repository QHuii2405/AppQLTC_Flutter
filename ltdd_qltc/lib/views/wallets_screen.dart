import 'package:flutter/material.dart';
import 'package:ltdd_qltc/models/user.dart';

class WalletsScreen extends StatelessWidget {
  final User user; // Nhận đối tượng User
  const WalletsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví Tiền Của Tôi'),
        backgroundColor: const Color(0xFF5CBDD9),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'Chào ${user.name}, đây là màn hình Ví tiền của bạn.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Các ví tiền của bạn sẽ được liệt kê tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
