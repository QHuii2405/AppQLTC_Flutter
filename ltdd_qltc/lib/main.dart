import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Models
import 'package:ltdd_qltc/models/user.dart';

// Controllers
import 'package:ltdd_qltc/controllers/account_controller.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';
import 'package:ltdd_qltc/controllers/category_controller.dart';
import 'package:ltdd_qltc/controllers/home_controller.dart';
import 'package:ltdd_qltc/controllers/transaction_controller.dart';

// Services
import 'package:ltdd_qltc/services/database_helper.dart';

// Views
import 'package:ltdd_qltc/views/auth_screen.dart';
import 'package:ltdd_qltc/views/home_screen.dart';
import 'package:ltdd_qltc/views/settings_screen.dart';
import 'package:ltdd_qltc/views/profile_screen.dart';
import 'package:ltdd_qltc/views/manage_accounts_screen.dart';
import 'package:ltdd_qltc/views/manage_categories_screen.dart';
import 'package:ltdd_qltc/views/change_password_screen.dart';
import 'package:ltdd_qltc/views/login_history_screen.dart';

void main() {
  // Đảm bảo Flutter bindings đã được khởi tạo trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized();

  // Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo một lần đối tượng DatabaseHelper
    final dbHelper = DatabaseHelper();

    // Sử dụng MultiProvider để cung cấp các controller cho toàn bộ ứng dụng
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(dbHelper)),
        ChangeNotifierProvider(create: (_) => HomeController(dbHelper)),
        ChangeNotifierProvider(create: (_) => AccountController(dbHelper)),
        ChangeNotifierProvider(create: (_) => CategoryController(dbHelper)),
        ChangeNotifierProvider(create: (_) => TransactionController(dbHelper)),
      ],
      child: MaterialApp(
        title: 'E-Wallet',
        debugShowCheckedModeBanner: false, // Tắt banner "Debug"
        // Cấu hình giao diện chung cho ứng dụng
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: const Color(0xFF4BAFCC),
          fontFamily: 'Roboto', // Có thể thay đổi font chữ tại đây
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5CBDD9),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5CBDD9),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        // Cấu hình địa phương hóa (localization) để hỗ trợ tiếng Việt
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('vi', 'VN'), // Vietnamese
        ],

        // Route ban đầu của ứng dụng
        initialRoute: '/signin',

        // Xử lý các route có tham số truyền vào
        onGenerateRoute: (settings) {
          final args = settings.arguments;

          switch (settings.name) {
            case '/signin':
              return MaterialPageRoute(builder: (_) => const AuthScreen());
            case '/home':
              // Đảm bảo rằng tham số là một đối tượng User
              if (args is User) {
                // `settings` được truyền vào để HomeScreen có thể nhận `arguments`
                return MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                  settings: settings,
                );
              }
              return _errorRoute();
            case '/settings':
              if (args is User) {
                return MaterialPageRoute(builder: (_) => SettingsScreen());
              }
              return _errorRoute();
            case '/profile':
              if (args is User) {
                return MaterialPageRoute(builder: (_) => ProfileScreen());
              }
              return _errorRoute();
            case '/manage_accounts':
              if (args is User) {
                return MaterialPageRoute(
                  builder: (_) => ManageAccountsScreen(),
                );
              }
              return _errorRoute();
            case '/manage_categories':
              if (args is User) {
                return MaterialPageRoute(
                  builder: (_) => ManageCategoriesScreen(),
                );
              }
              return _errorRoute();
            case '/change_password':
              if (args is User) {
                return MaterialPageRoute(
                  builder: (_) => ChangePasswordScreen(),
                );
              }
              return _errorRoute();
            case '/login_history':
              if (args is User) {
                return MaterialPageRoute(builder: (_) => LoginHistoryScreen());
              }
              return _errorRoute();
            default:
              // Nếu không tìm thấy route, hiển thị màn hình lỗi
              return _errorRoute();
          }
        },
      ),
    );
  }

  // Hàm trợ giúp để trả về một route lỗi
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Lỗi')),
          body: const Center(child: Text('Đã xảy ra lỗi điều hướng!')),
        );
      },
    );
  }
}
