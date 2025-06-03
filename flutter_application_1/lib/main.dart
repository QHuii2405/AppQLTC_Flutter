import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/security_setting_screen.dart';
import 'package:flutter_application_1/views/setting_profile_screen.dart';
import 'package:flutter_application_1/views/setting_screen.dart';
import 'package:provider/provider.dart'; // Import Provider package

// Import các màn hình và controller của bạn
import 'package:flutter_application_1/views/login_screen.dart'; // Màn hình đăng nhập
import 'package:flutter_application_1/views/signin_screen.dart'; // Màn hình đăng ký/đăng nhập
import 'package:flutter_application_1/views/home_screen.dart'; // Màn hình chính
import 'package:flutter_application_1/controllers/home_controller.dart'; // HomeController của bạn
import 'package:flutter_application_1/controllers/settings_controller.dart'; // SettingsController của bạn
import 'package:flutter_application_1/controllers/profile_controller.dart'; // Import ProfileController mới
import 'package:flutter_application_1/models/user.dart'; // User model
import 'package:flutter_application_1/services/database_helper.dart'; // Import DatabaseHelper

void main() {
  // Khởi tạo DatabaseHelper một lần duy nhất
  final DatabaseHelper dbHelper = DatabaseHelper();

  runApp(
    // Sử dụng MultiProvider để cung cấp nhiều Provider cho toàn bộ ứng dụng
    MultiProvider(
      providers: [
        // Cung cấp HomeController dưới dạng ChangeNotifierProvider
        ChangeNotifierProvider(create: (context) => HomeController(dbHelper)),
        // Cung cấp SettingsController dưới dạng ChangeNotifierProvider
        ChangeNotifierProvider(
          create: (context) => SettingsController(dbHelper),
        ),
        // Cung cấp ProfileController dưới dạng ChangeNotifierProvider
        ChangeNotifierProvider(
          create: (context) => ProfileController(dbHelper), // Truyền dbHelper
        ),
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
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        // '/wallets': (context) => WalletsScreen(),
        // '/statistics': (context) => StatisticsScreen(),
        '/security_settings':
            (context) => const SecuritySettingsScreen(), // Đã thêm route này
        // Thêm các route khác của bạn ở đây
      },
      // Nếu bạn muốn xử lý route động hoặc truyền đối tượng User trực tiếp
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/home') {
      //     final user = settings.arguments as User?;
      //     return MaterialPageRoute(builder: (context) => HomeScreen(user: user));
      //   }
      //   return null;
      // },
    );
  }
}
