import 'package:sqflite/sqflite.dart' as sqflite_api;
import 'package:path/path.dart';
import 'dart:math'; // Dùng để tạo số ngẫu nhiên cho token
import 'package:intl/intl.dart'; // Để định dạng ngày tháng
import 'dart:core'; // Đã thêm import này để đảm bảo DateTime được định nghĩa

// Import các Model classes
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/account.dart';
import 'package:ltdd_qltc/models/category.dart';
import 'package:ltdd_qltc/models/transaction.dart';
// import 'package:ltdd_qltc/models/login_history.dart';

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
      onUpgrade: _onUpgrade, // Thêm onUpgrade
    );
  }

  Future<void> _onCreate(sqflite_api.Database db, int version) async {
    // Tạo bảng Users
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

    // Tạo bảng Accounts (Ví tiền)
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

    // Tạo bảng Categories (Danh mục)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL, -- 'income' or 'expense'
        icon TEXT, -- Tên icon hoặc path
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng Transactions (Giao dịch)
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
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng LoginHistory
    await db.execute('''
      CREATE TABLE login_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        login_time TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // Phương thức onUpgrade để xử lý các thay đổi schema trong tương lai (nếu cần)
  Future<void> _onUpgrade(
    sqflite_api.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Ví dụ: Nếu bạn cần thêm cột mới trong phiên bản 2
    if (oldVersion < 1) {
      // Logic nâng cấp từ version 1 nếu có
    }
    // Cập nhật schema cho bảng `users` để thêm `profile_image_url`, `dob`, `description`
    if (oldVersion < 1) {
      // Giả sử những cột này được thêm từ version 1 trở đi
      await db.execute('ALTER TABLE users ADD COLUMN profile_image_url TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN dob TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN description TEXT');
    }
    // Nếu có các thay đổi khác trong các phiên bản sau, bạn có thể thêm logic ở đây
  }

  // --- User operations ---
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

  // Phương thức cập nhật thông tin người dùng (MỚI)
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
    final token = (Random().nextInt(900000) + 100000).toString(); // Mã 6 chữ số
    final expires = DateTime.now()
        .add(const Duration(minutes: 10))
        .millisecondsSinceEpoch; // Hết hạn sau 10 phút

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
          'password': newPassword, // Cập nhật mật khẩu mới
          'reset_token': null, // Xóa token sau khi sử dụng
          'reset_token_expires': null,
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return true;
    }
    return false;
  }

  // --- Account operations ---
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
    return List.generate(maps.length, (i) {
      return Account.fromMap(maps[i]);
    });
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

  // --- Category operations ---
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
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
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

  // --- Transaction operations ---
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
    // Thực hiện JOIN để lấy category name và account name
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        T.*,
        C.name AS category_name,
        C.icon AS category_icon,
        A.name AS account_name
      FROM transactions AS T
      INNER JOIN categories AS C ON T.category_id = C.id
      INNER JOIN accounts AS A ON T.account_id = A.id
      WHERE T.user_id = ?
      ORDER BY T.transaction_date DESC, T.created_at DESC
    ''',
      [userId],
    );

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
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

  // --- Login History operations ---
  // Future<int> insertLoginHistory(int userId) async {
  //   final db = await database;
  //   final loginEntry = LoginHistory(
  //     userId: userId,
  //     loginTime: DateTime.now().toIso8601String(),
  //   );
  //   return await db.insert('login_history', loginEntry.toMapWithoutId(), conflictAlgorithm: sqflite_api.ConflictAlgorithm.replace);
  // }

  // Future<List<LoginHistory>> getLoginHistory(int userId) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'login_history',
  //     where: 'user_id = ?',
  //     whereArgs: [userId],
  //     orderBy: 'login_time DESC',
  //   );
  //   return List.generate(maps.length, (i) {
  //     return LoginHistory.fromMap(maps[i]);
  //   });
  // }

  // --- Sample Data Insertion ---
  Future<void> insertInitialSampleData(int userId) async {
    final db = await database;

    // Kiểm tra xem đã có dữ liệu mẫu cho người dùng này chưa
    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (accounts.isNotEmpty) {
      print('Dữ liệu mẫu đã tồn tại cho người dùng $userId, bỏ qua chèn.');
      return; // Đã có dữ liệu, không chèn lại
    }

    print('Bắt đầu chèn dữ liệu mẫu cho người dùng $userId...');

    // Lấy thời gian hiện tại
    String currentTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    // 1. Thêm ví tiền mặc định
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

    print(
      'Đã chèn ví mẫu: Ví chính (ID: $mainWalletId), Ngân hàng (ID: $bankAccountId)',
    );

    // 2. Thêm danh mục mặc định
    final foodCategory = Category(
      userId: userId,
      name: 'Ăn uống',
      type: 'expense',
      icon: '🍽️',
      createdAt: currentTime,
    );
    final travelCategory = Category(
      userId: userId,
      name: 'Du lịch',
      type: 'expense',
      icon: '✈️',
      createdAt: currentTime,
    );
    final shoppingCategory = Category(
      userId: userId,
      name: 'Mua sắm',
      type: 'expense',
      icon: '🛍️',
      createdAt: currentTime,
    );
    final transportationCategory = Category(
      userId: userId,
      name: 'Di chuyển',
      type: 'expense',
      icon: '🚗',
      createdAt: currentTime,
    );
    final healthcareCategory = Category(
      userId: userId,
      name: 'Chữa bệnh',
      type: 'expense',
      icon: '🏥',
      createdAt: currentTime,
    );
    final billsCategory = Category(
      userId: userId,
      name: 'Hóa đơn',
      type: 'expense',
      icon: '🧾',
      createdAt: currentTime,
    );

    final salaryCategory = Category(
      userId: userId,
      name: 'Tiền lương',
      type: 'income',
      icon: '💰',
      createdAt: currentTime,
    );
    final bonusCategory = Category(
      userId: userId,
      name: 'Tiền thưởng',
      type: 'income',
      icon: '🎁',
      createdAt: currentTime,
    );
    final otherIncomeCategory = Category(
      userId: userId,
      name: 'Thu nhập khác',
      type: 'income',
      icon: '📈',
      createdAt: currentTime,
    );

    int foodCategoryId = await insertCategory(foodCategory);
    int travelCategoryId = await insertCategory(travelCategory);
    int shoppingCategoryId = await insertCategory(shoppingCategory);
    int transportationCategoryId = await insertCategory(transportationCategory);
    int healthcareCategoryId = await insertCategory(healthcareCategory);
    int billsCategoryId = await insertCategory(billsCategory);
    int salaryCategoryId = await insertCategory(salaryCategory);
    int bonusCategoryId = await insertCategory(bonusCategory);
    int otherIncomeCategoryId = await insertCategory(otherIncomeCategory);

    print('Đã chèn danh mục mẫu.');

    // 3. Thêm một số giao dịch mẫu
    DateTime now = DateTime.now();
    String today = DateFormat('yyyy-MM-dd').format(now);
    String yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 1)));
    String twoDaysAgo = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 2)));
    String threeDaysAgo = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 3)));
    String lastWeek = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 7)));

    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'expense',
        categoryId: foodCategoryId,
        amount: 50000.0,
        description: 'Ăn sáng tại quán',
        transactionDate: today,
        paymentMethod: 'Tiền mặt',
        accountId: mainWalletId,
        createdAt: currentTime,
      ),
    );
    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'expense',
        categoryId: billsCategoryId,
        amount: 150000.0,
        description: 'Tiền điện tháng 5',
        transactionDate: today,
        paymentMethod: 'Chuyển khoản',
        accountId: bankAccountId,
        createdAt: currentTime,
      ),
    );
    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'income',
        categoryId: salaryCategoryId,
        amount: 1000000.0,
        description: 'Nhận lương tháng 5',
        transactionDate: yesterday,
        paymentMethod: 'Chuyển khoản',
        accountId: bankAccountId,
        createdAt: currentTime,
      ),
    );
    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'expense',
        categoryId: shoppingCategoryId,
        amount: 250000.0,
        description: 'Mua sắm quần áo',
        transactionDate: twoDaysAgo,
        paymentMethod: 'Thẻ tín dụng',
        accountId: bankAccountId,
        createdAt: currentTime,
      ),
    );
    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'expense',
        categoryId: transportationCategoryId,
        amount: 20000.0,
        description: 'Tiền xăng xe',
        transactionDate: threeDaysAgo,
        paymentMethod: 'Tiền mặt',
        accountId: mainWalletId,
        createdAt: currentTime,
      ),
    );
    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'income',
        categoryId: bonusCategoryId,
        amount: 200000.0,
        description: 'Tiền thưởng dự án',
        transactionDate: lastWeek,
        paymentMethod: 'Chuyển khoản',
        accountId: bankAccountId,
        createdAt: currentTime,
      ),
    );

    print('Đã chèn giao dịch mẫu.');
    print('Hoàn tất chèn dữ liệu mẫu.');
  }

  // Tạo ví tiền mặc định và danh mục cho người dùng mới đăng ký
  Future<void> createDefaultAccountAndCategories(int userId) async {
    final db = await database;
    String currentTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    // Ví chính
    final defaultWallet = Account(
      userId: userId,
      name: 'Ví chính',
      balance: 0.0, // Số dư ban đầu là 0
      currency: 'VND',
      createdAt: currentTime,
    );
    await insertAccount(defaultWallet);
    print('Đã tạo ví chính mặc định cho người dùng $userId.');

    // Danh mục chi tiêu mặc định
    await insertCategory(
      Category(
        userId: userId,
        name: 'Ăn uống',
        type: 'expense',
        icon: '🍽️',
        createdAt: currentTime,
      ),
    );
    await insertCategory(
      Category(
        userId: userId,
        name: 'Mua sắm',
        type: 'expense',
        icon: '🛍️',
        createdAt: currentTime,
      ),
    );
    await insertCategory(
      Category(
        userId: userId,
        name: 'Di chuyển',
        type: 'expense',
        icon: '🚗',
        createdAt: currentTime,
      ),
    );
    await insertCategory(
      Category(
        userId: userId,
        name: 'Hóa đơn',
        type: 'expense',
        icon: '🧾',
        createdAt: currentTime,
      ),
    );
    await insertCategory(
      Category(
        userId: userId,
        name: 'Giải trí',
        type: 'expense',
        icon: '🎉',
        createdAt: currentTime,
      ),
    );

    // Danh mục thu nhập mặc định
    await insertCategory(
      Category(
        userId: userId,
        name: 'Tiền lương',
        type: 'income',
        icon: '💰',
        createdAt: currentTime,
      ),
    );
    await insertCategory(
      Category(
        userId: userId,
        name: 'Tiền thưởng',
        type: 'income',
        icon: '🎁',
        createdAt: currentTime,
      ),
    );
    await insertCategory(
      Category(
        userId: userId,
        name: 'Thu nhập khác',
        type: 'income',
        icon: '📈',
        createdAt: currentTime,
      ),
    );
    print('Đã tạo danh mục mặc định cho người dùng $userId.');
  }
}
