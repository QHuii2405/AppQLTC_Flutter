import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/profile_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/views/login_screen.dart';
import 'package:flutter_application_1/views/signin_screen.dart';
import 'package:flutter_application_1/views/home_screen.dart';
import 'package:flutter_application_1/views/setting_profile_screen.dart';
import 'package:flutter_application_1/views/setting_screen.dart';
import 'package:flutter_application_1/controllers/home_controller.dart';
import 'package:flutter_application_1/controllers/settings_controller.dart';
import 'package:flutter_application_1/services/database_helper.dart';

void main() {
  // Khởi tạo DatabaseHelper một lần duy nhất
  final DatabaseHelper dbHelper = DatabaseHelper();

  runApp(
    // Sử dụng MultiProvider để cung cấp nhiều Provider cho toàn bộ ứng dụng
    MultiProvider(
      providers: [
        // Cung cấp các Controller dưới dạng ChangeNotifierProvider
        ChangeNotifierProvider(create: (context) => HomeController(dbHelper)),
        ChangeNotifierProvider(create: (context) => SettingsController()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  ProfileController(dbHelper), // Truyền dbHelper nếu cần
        ),
        // Bạn có thể thêm các Provider khác ở đây nếu cần
      ],
      child: MyApp(), // Ứng dụng của bạn
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EWallet App',
      debugShowCheckedModeBanner: false, // Tắt banner debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Đặt font Inter cho toàn bộ ứng dụng
      ),
      initialRoute: '/signin', // Màn hình khởi đầu của ứng dụng
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signin': (context) => const SigninScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        // '/wallets': (context) => WalletsScreen(),
        // '/statistics': (context) => StatisticsScreen(),
        // Thêm các route khác của bạn ở đây
      },
    );
  }
}
