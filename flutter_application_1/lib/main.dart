import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các màn hình và controller của bạn
import 'package:flutter_application_1/views/login_screen.dart'; // Màn hình đăng nhập (nếu có)
import 'package:flutter_application_1/views/signin_screen.dart'; // Màn hình đăng ký/đăng nhập
import 'package:flutter_application_1/views/home_screen.dart'; // Màn hình chính
import 'package:flutter_application_1/views/profile_screen.dart'; // Màn hình Profile
import 'package:flutter_application_1/views/settings_screen.dart'; // Màn hình cài đặt
import 'package:flutter_application_1/views/wallets_screen.dart'; // Màn hình ví tiền
import 'package:flutter_application_1/views/statistics_screen.dart'; // Màn hình thống kê
import 'package:flutter_application_1/views/security_settings_screen.dart'; // Màn hình Bảo mật mới
import 'package:flutter_application_1/views/category_management_screen.dart'; // Import màn hình quản lý thể loại

import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:flutter_application_1/controllers/home_controller.dart';
import 'package:flutter_application_1/controllers/settings_controller.dart';
import 'package:flutter_application_1/controllers/profile_controller.dart';
import 'package:flutter_application_1/controllers/security_controller.dart'; // Import SecurityController
import 'package:flutter_application_1/controllers/category_controller.dart'; // Import CategoryController

import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/database_helper.dart';

void main() {
  final DatabaseHelper dbHelper = DatabaseHelper();

  runApp(
    MultiProvider(
      providers: [
        // Cung cấp AuthController
        ChangeNotifierProvider(
          create: (context) => AuthController(dbHelper),
        ),
        // Cung cấp HomeController
        ChangeNotifierProvider(
          create: (context) => HomeController(dbHelper),
        ),
        // Cung cấp SettingsController
        ChangeNotifierProvider(
          create: (context) => SettingsController(dbHelper),
        ),
        // Cung cấp ProfileController
        ChangeNotifierProvider(
          create: (context) => ProfileController(dbHelper),
        ),
        // Cung cấp SecurityController
        ChangeNotifierProvider(
          create: (context) => SecurityController(dbHelper),
        ),
        // Cung cấp CategoryController
        ChangeNotifierProvider(
          create: (context) => CategoryController(dbHelper),
        ),
        // Thêm các Controller khác ở đây
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EWallet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      initialRoute: '/signin',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signin': (context) => const SigninScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => const ProfileScreen(), // Constructor là const
        '/settings': (context) => const SettingsScreen(), // Constructor là const
        '/wallets': (context) => WalletsScreen(),
        '/statistics': (context) => StatisticsScreen(),
        '/security_settings': (context) => const SecuritySettingsScreen(), // Constructor là const
        '/category_management': (context) => CategoryManagementScreen(), // Không dùng const vì nhận arguments
      },
    );
  }
}
