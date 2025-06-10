import 'package:sqflite/sqflite.dart' as sqflite_api;
import 'package:path/path.dart';
import 'dart:math';
import 'package:intl/intl.dart';

// Import các lớp Model
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/account.dart';
import 'package:ltdd_qltc/models/category.dart';
import 'package:ltdd_qltc/models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static sqflite_api.Database? _database;

  Future<sqflite_api.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqflite_api.Database> _initDatabase() async {
    String path = join(await sqflite_api.getDatabasesPath(), 'ewallet.db');
    return await sqflite_api.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Khởi tạo cấu trúc các bảng trong database
  Future<void> _onCreate(sqflite_api.Database db, int version) async {
    // Bảng users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        reset_token TEXT,
        reset_token_expires INTEGER,
        profile_image_url TEXT,
        dob TEXT,
        description TEXT
      )
    ''');

    // Bảng accounts (Ví tiền)
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        currency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Bảng categories (Danh mục)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL, -- 'income' or 'expense'
        icon TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Bảng transactions (Giao dịch)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL, -- 'income' or 'expense'
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        transaction_date TEXT NOT NULL,
        payment_method TEXT,
        account_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Các hàm xử lý User ---
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMapWithoutId(),
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> updateUserResetToken(
      String email, String? resetToken, int? resetTokenExpires) async {
    final db = await database;
    final int rowsAffected = await db.update(
      'users',
      {'reset_token': resetToken, 'reset_token_expires': resetTokenExpires},
      where: 'email = ?',
      whereArgs: [email],
    );
    return rowsAffected > 0;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> updateUser(User user) async {
    final db = await database;
    int rowsAffected = await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
    return rowsAffected > 0;
  }

  Future<String> generateAndSaveResetToken(int userId) async {
    final db = await database;
    final token = (Random().nextInt(900000) + 100000).toString();
    final expires = DateTime.now()
        .add(const Duration(minutes: 10))
        .millisecondsSinceEpoch;

    await db.update(
      'users',
      {'reset_token': token, 'reset_token_expires': expires},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return token;
  }

  Future<bool> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND reset_token = ? AND reset_token_expires > ?',
      whereArgs: [email, token, DateTime.now().millisecondsSinceEpoch],
    );

    if (maps.isNotEmpty) {
      final user = User.fromMap(maps.first);
      await db.update(
        'users',
        {
          'password': newPassword,
          'reset_token': null,
          'reset_token_expires': null,
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return true;
    }
    return false;
  }


  // --- Các hàm xử lý Account ---
  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert(
      'accounts',
      account.toMapWithoutId(),
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
  }

  Future<List<Account>> getAccounts(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // --- Các hàm xử lý Category ---
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMapWithoutId(),
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getCategories(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Các hàm xử lý Transaction ---
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert(
      'transactions',
      transaction.toMapWithoutId(),
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        T.*,
        C.name AS category_name,
        C.icon AS category_icon,
        A.name AS account_name
      FROM transactions AS T
      LEFT JOIN categories AS C ON T.category_id = C.id
      LEFT JOIN accounts AS A ON T.account_id = A.id
      WHERE T.user_id = ?
      ORDER BY T.transaction_date DESC, T.id DESC
    ''',
      [userId],
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
      conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Các hàm khởi tạo dữ liệu ---
  Future<void> createDefaultAccountAndCategories(int userId) async {
    String currentTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    // Tạo Ví chính
    final defaultWallet = Account(
      userId: userId,
      name: 'Ví chính',
      balance: 0.0,
      currency: 'VND',
      createdAt: currentTime,
    );
    await insertAccount(defaultWallet);

    // Tạo các danh mục mặc định
    final defaultCategories = [
      Category(
        userId: userId,
        name: 'Ăn uống',
        type: 'expense',
        icon: '🍽️',
        createdAt: currentTime,
      ),
      Category(
        userId: userId,
        name: 'Mua sắm',
        type: 'expense',
        icon: '🛍️',
        createdAt: currentTime,
      ),
      Category(
        userId: userId,
        name: 'Di chuyển',
        type: 'expense',
        icon: '🚗',
        createdAt: currentTime,
      ),
      Category(
        userId: userId,
        name: 'Hóa đơn',
        type: 'expense',
        icon: '🧾',
        createdAt: currentTime,
      ),
      Category(
        userId: userId,
        name: 'Giải trí',
        type: 'expense',
        icon: '🎉',
        createdAt: currentTime,
      ),
      Category(
        userId: userId,
        name: 'Tiền lương',
        type: 'income',
        icon: '💰',
        createdAt: currentTime,
      ),
      Category(
        userId: userId,
        name: 'Tiền thưởng',
        type: 'income',
        icon: '🎁',
        createdAt: currentTime,
      ),
      Category(
        userId: userId,
        name: 'Thu nhập khác',
        type: 'income',
        icon: '📈',
        createdAt: currentTime,
      ),
    ];

    for (var category in defaultCategories) {
      await insertCategory(category);
    }
  }

  Future<void> insertInitialSampleData(int userId) async {
    final db = await database;
    final accounts = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final transactions = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    // Chỉ thêm dữ liệu mẫu nếu người dùng chưa có ví và chưa có giao dịch
    if (accounts.isNotEmpty || transactions.isNotEmpty) {
      return;
    }

    String currentTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    // 1. Thêm ví mẫu
    final mainWallet = Account(
      userId: userId,
      name: 'Ví chính',
      balance: 5000000.0,
      currency: 'VND',
      createdAt: currentTime,
    );
    final bankAccount = Account(
      userId: userId,
      name: 'Tài khoản ngân hàng',
      balance: 10000000.0,
      currency: 'VND',
      createdAt: currentTime,
    );
    int mainWalletId = await insertAccount(mainWallet);
    int bankAccountId = await insertAccount(bankAccount);

    // 2. Thêm danh mục mẫu
    await createDefaultAccountAndCategories(userId);
    final categories = await getCategories(userId);
    final foodCategory = categories.firstWhere((c) => c.name == 'Ăn uống');
    final salaryCategory = categories.firstWhere((c) => c.name == 'Tiền lương');

    // 3. Thêm giao dịch mẫu
    DateTime now = DateTime.now();
    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'expense',
        categoryId: foodCategory.id!,
        amount: 50000.0,
        description: 'Ăn sáng tại quán',
        transactionDate: DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 1))),
        paymentMethod: 'Tiền mặt',
        accountId: mainWalletId,
        createdAt: currentTime,
      ),
    );
    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'income',
        categoryId: salaryCategory.id!,
        amount: 12000000.0,
        description: 'Lương tháng này',
        transactionDate: DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 5))),
        paymentMethod: 'Chuyển khoản',
        accountId: bankAccountId,
        createdAt: currentTime,
      ),
    );
  }
}
