import 'package:flutter/material.dart';
import 'package:ltdd_qltc/views/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import thư viện bản địa hóa (cần thiết cho DatePicker)

import 'package:ltdd_qltc/services/database_helper.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';
import 'package:ltdd_qltc/controllers/theme_provider.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';
import 'package:ltdd_qltc/views/home_screen.dart';
import 'package:ltdd_qltc/models/user.dart';

// Import các màn hình con đã tạo
import 'package:ltdd_qltc/views/profile_screen.dart';
import 'package:ltdd_qltc/views/wallets_screen.dart';
import 'package:ltdd_qltc/views/add_transaction_screen.dart';
import 'package:ltdd_qltc/views/statistics_screen.dart';
import 'package:ltdd_qltc/views/settings_screen.dart';
import 'package:ltdd_qltc/views/manage_accounts_screen.dart';
import 'package:ltdd_qltc/views/manage_categories_screen.dart';
import 'package:ltdd_qltc/views/change_password_screen.dart';
import 'package:ltdd_qltc/views/login_history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseHelper = DatabaseHelper();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(databaseHelper)),
        ChangeNotifierProvider(create: (_) => HomeController(databaseHelper)),
        ChangeNotifierProvider(
          create: (_) => CategoryController(databaseHelper),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionController(databaseHelper),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AccountController(databaseHelper),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Quản Lý Thu Chi',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Inter',
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF5CBDD9),
                foregroundColor: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Inter',
              brightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.grey[850],
            ),

            // Cần thiết cho DatePickerDialog để hoạt động, ngay cả khi không bản địa hóa cụ thể
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              // GlobalCupertinoLocalizations.delegate, // Tùy chọn, chỉ cần nếu bạn dùng widget Cupertino
            ],
            // Chỉ hỗ trợ tiếng Anh nếu bạn không muốn bản địa hóa tiếng Việt.
            // DatePicker sẽ hiển thị bằng tiếng Anh nếu không có locale nào khác được thiết bị hỗ trợ.
            supportedLocales: const [
              // Đã thêm 'const' vào Locale
              const Locale('en', 'US'),
            ],

            // locale: const Locale('vi', 'VN'), // Bỏ comment nếu bạn muốn ép buộc tiếng Việt ngay lập tức
            initialRoute: '/signin',
            routes: {
              '/signin': (context) => const SigninScreen(),
              '/home': (context) => const HomeScreen(),
              '/profile': (context) => ProfileScreen(
                user:
                    ModalRoute.of(context)?.settings.arguments as User? ??
                    User(
                      email: '',
                      password: '',
                      name: 'Guest',
                      createdAt: DateTime.now().toIso8601String(),
                    ),
              ),
              '/manage_accounts': (context) => ManageAccountsScreen(
                user:
                    ModalRoute.of(context)?.settings.arguments as User? ??
                    User(
                      email: '',
                      password: '',
                      name: 'Guest',
                      createdAt: DateTime.now().toIso8601String(),
                    ),
              ),
              '/manage_categories': (context) => ManageCategoriesScreen(
                user:
                    ModalRoute.of(context)?.settings.arguments as User? ??
                    User(
                      email: '',
                      password: '',
                      name: 'Guest',
                      createdAt: DateTime.now().toIso8601String(),
                    ),
              ),
              '/change_password': (context) => ChangePasswordScreen(
                user:
                    ModalRoute.of(context)?.settings.arguments as User? ??
                    User(
                      email: '',
                      password: '',
                      name: 'Guest',
                      createdAt: DateTime.now().toIso8601String(),
                    ),
              ),
              '/login_history': (context) => LoginHistoryScreen(
                user:
                    ModalRoute.of(context)?.settings.arguments as User? ??
                    User(
                      email: '',
                      password: '',
                      name: 'Guest',
                      createdAt: DateTime.now().toIso8601String(),
                    ),
              ),
              '/add_transaction': (context) => AddTransactionScreen(
                user:
                    ModalRoute.of(context)?.settings.arguments as User? ??
                    User(
                      email: '',
                      password: '',
                      name: 'Guest',
                      createdAt: DateTime.now().toIso8601String(),
                    ),
              ),
            },
          );
        },
      ),
    );
  }
}
