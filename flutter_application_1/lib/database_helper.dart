import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ewallet.db');
    return await openDatabase(
      path,
      version: 2, // Tăng version để cập nhật schema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        reset_token TEXT,
        reset_token_expires INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm cột reset_token và reset_token_expires cho version 2
      await db.execute('ALTER TABLE users ADD COLUMN reset_token TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN reset_token_expires INTEGER');
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> checkEmailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  // Tạo reset token cho email
  Future<String?> createResetToken(String email) async {
    Database db = await database;
    
    // Kiểm tra email có tồn tại không
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (results.isEmpty) {
      return null; // Email không tồn tại
    }
    
    // Tạo reset token (6 chữ số ngẫu nhiên)
    String resetToken = _generateResetToken();
    int expiresAt = DateTime.now().add(Duration(minutes: 15)).millisecondsSinceEpoch;
    
    // Lưu reset token vào database
    await db.update(
      'users',
      {
        'reset_token': resetToken,
        'reset_token_expires': expiresAt,
      },
      where: 'email = ?',
      whereArgs: [email],
    );
    
    return resetToken;
  }

  // Xác thực reset token
  Future<bool> verifyResetToken(String email, String token) async {
    Database db = await database;
    
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND reset_token = ?',
      whereArgs: [email, token],
    );
    
    if (results.isEmpty) {
      return false;
    }
    
    // Kiểm tra token có hết hạn không
    int? expiresAt = results.first['reset_token_expires'];
    if (expiresAt == null || DateTime.now().millisecondsSinceEpoch > expiresAt) {
      return false;
    }
    
    return true;
  }

  // Reset mật khẩu
  Future<bool> resetPassword(String email, String token, String newPassword) async {
    Database db = await database;
    
    // Xác thực token trước
    if (!await verifyResetToken(email, token)) {
      return false;
    }
    
    // Cập nhật mật khẩu và xóa reset token
    int rowsAffected = await db.update(
      'users',
      {
        'password': newPassword,
        'reset_token': null,
        'reset_token_expires': null,
      },
      where: 'email = ? AND reset_token = ?',
      whereArgs: [email, token],
    );
    
    return rowsAffected > 0;
  }

  // Tạo mã reset token 6 chữ số
  String _generateResetToken() {
    var random = DateTime.now().millisecondsSinceEpoch;
    return (100000 + (random % 900000)).toString();
  }

  // Xóa các token đã hết hạn
  Future<void> cleanExpiredTokens() async {
    Database db = await database;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    
    await db.update(
      'users',
      {
        'reset_token': null,
        'reset_token_expires': null,
      },
      where: 'reset_token_expires < ?',
      whereArgs: [currentTime],
    );
  }

  Future<void> close() async {
    Database db = await database;
    await db.close();
  }
}