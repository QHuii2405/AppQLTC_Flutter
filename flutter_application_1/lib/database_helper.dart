import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart'; // Import này có thể không cần thiết nếu chỉ dùng DateTime.toIso8601String()
import 'dart:math'; // Dùng để tạo số ngẫu nhiên cho token

class DatabaseHelper {
  // Instance Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter cho instance database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Khởi tạo database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ewallet.db');
    return await openDatabase(
      path,
      version: 3, // Tăng version lên 3 cho các bảng mới
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Tạo các bảng khi database được tạo lần đầu
  Future _onCreate(Database db, int version) async {
    // Tạo bảng users
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

    // Tạo bảng accounts (tài khoản/ví)
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        balance REAL DEFAULT 0.0,
        currency TEXT DEFAULT 'VND',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng categories (danh mục)
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL, -- 'income' (thu) hoặc 'expense' (chi)
        icon TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng transactions (giao dịch)
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL, -- 'income' (thu) hoặc 'expense' (chi)
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        transaction_date TEXT NOT NULL,
        payment_method TEXT,
        account_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
      )
    ''');

    // Chèn người dùng admin mặc định
    final String currentTime = DateTime.now().toIso8601String();
    await db.insert('users', {
      'email': 'admin@example.com',
      'password':
          'admin_password', // Trong ứng dụng thực tế, hãy mã hóa mật khẩu này!
      'name': 'Người dùng Admin',
      'created_at': currentTime,
    });

    print('Database đã được tạo và người dùng admin đã được chèn.');
  }

  // Xử lý nâng cấp schema database
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm cột reset_token và reset_token_expires cho version 2
      await db.execute('ALTER TABLE users ADD COLUMN reset_token TEXT');
      await db.execute(
        'ALTER TABLE users ADD COLUMN reset_token_expires INTEGER',
      );
      print(
        'Đã nâng cấp lên version 2: Đã thêm cột reset_token vào bảng users.',
      );
    }
    if (oldVersion < 3) {
      // Tạo các bảng mới cho version 3
      await db.execute('''
        CREATE TABLE accounts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          balance REAL DEFAULT 0.0,
          currency TEXT DEFAULT 'VND',
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL, -- 'income' (thu) hoặc 'expense' (chi)
          icon TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          type TEXT NOT NULL, -- 'income' (thu) hoặc 'expense' (chi)
          category_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          description TEXT,
          transaction_date TEXT NOT NULL,
          payment_method TEXT,
          account_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');
      print(
        'Đã nâng cấp lên version 3: Đã tạo các bảng accounts, categories và transactions.',
      );
    }
  }

  // --- Phương thức quản lý người dùng ---

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

  // Tạo mã reset token cho email
  Future<String?> createResetToken(String email) async {
    Database db = await database;

    // Kiểm tra xem email có tồn tại không
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isEmpty) {
      return null; // Email không tồn tại
    }

    // Tạo mã reset token (6 chữ số ngẫu nhiên)
    String resetToken = _generateResetToken();
    int expiresAt =
        DateTime.now().add(Duration(minutes: 15)).millisecondsSinceEpoch;

    // Lưu mã reset token vào database
    await db.update(
      'users',
      {'reset_token': resetToken, 'reset_token_expires': expiresAt},
      where: 'email = ?',
      whereArgs: [email],
    );

    return resetToken;
  }

  // Xác thực mã reset token
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

    // Kiểm tra xem token đã hết hạn chưa
    int? expiresAt = results.first['reset_token_expires'];
    if (expiresAt == null ||
        DateTime.now().millisecondsSinceEpoch > expiresAt) {
      return false;
    }

    return true;
  }

  // Đặt lại mật khẩu
  Future<bool> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
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
    var rng = Random();
    return (rng.nextInt(900000) + 100000)
        .toString(); // Tạo số từ 100000 đến 999999
  }

  // Xóa các token đã hết hạn
  Future<void> cleanExpiredTokens() async {
    Database db = await database;
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'users',
      {'reset_token': null, 'reset_token_expires': null},
      where: 'reset_token_expires < ?',
      whereArgs: [currentTime],
    );
  }

  // --- Phương thức quản lý tài khoản ---

  Future<int> insertAccount(Map<String, dynamic> account) async {
    Database db = await database;
    return await db.insert('accounts', account);
  }

  Future<List<Map<String, dynamic>>> getAccounts(int userId) async {
    Database db = await database;
    return await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateAccount(Map<String, dynamic> account) async {
    Database db = await database;
    return await db.update(
      'accounts',
      account,
      where: 'id = ?',
      whereArgs: [account['id']],
    );
  }

  Future<int> deleteAccount(int id) async {
    Database db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // --- Phương thức quản lý danh mục ---

  Future<int> insertCategory(Map<String, dynamic> category) async {
    Database db = await database;
    return await db.insert('categories', category);
  }

  Future<List<Map<String, dynamic>>> getCategories(int userId) async {
    Database db = await database;
    return await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    Database db = await database;
    return await db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Phương thức quản lý giao dịch ---

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    Database db = await database;
    // Khi chèn một giao dịch, cũng cập nhật số dư tài khoản
    await db.transaction((txn) async {
      int transactionId = await txn.insert('transactions', transaction);

      // Cập nhật số dư tài khoản
      double amount = transaction['amount'];
      String type = transaction['type']; // 'income' (thu) hoặc 'expense' (chi)
      int accountId = transaction['account_id'];

      // Lấy số dư tài khoản hiện tại
      List<Map<String, dynamic>> accountResult = await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [accountId],
      );

      if (accountResult.isNotEmpty) {
        double currentBalance = accountResult.first['balance'];
        double newBalance;
        if (type == 'income') {
          newBalance = currentBalance + amount;
        } else {
          newBalance = currentBalance - amount;
        }

        await txn.update(
          'accounts',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [accountId],
        );
      }
      return transactionId;
    });
    return 1; // Chỉ ra thành công, transactionId thực tế được xử lý bên trong db.transaction
  }

  Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    Database db = await database;
    // Bạn có thể muốn join với bảng categories và accounts để có kết quả chi tiết hơn
    return await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transaction_date DESC',
    );
  }

  Future<int> updateTransaction(
    Map<String, dynamic> oldTransaction,
    Map<String, dynamic> newTransaction,
  ) async {
    Database db = await database;

    await db.transaction((txn) async {
      // Hoàn tác ảnh hưởng của giao dịch cũ lên số dư tài khoản
      double oldAmount = oldTransaction['amount'];
      String oldType = oldTransaction['type'];
      int oldAccountId = oldTransaction['account_id'];

      List<Map<String, dynamic>> oldAccountResult = await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [oldAccountId],
      );

      if (oldAccountResult.isNotEmpty) {
        double currentBalance = oldAccountResult.first['balance'];
        double balanceAfterRevert;
        if (oldType == 'income') {
          balanceAfterRevert = currentBalance - oldAmount;
        } else {
          balanceAfterRevert = currentBalance + oldAmount;
        }
        await txn.update(
          'accounts',
          {'balance': balanceAfterRevert},
          where: 'id = ?',
          whereArgs: [oldAccountId],
        );
      }

      // Áp dụng ảnh hưởng của giao dịch mới lên số dư tài khoản
      double newAmount = newTransaction['amount'];
      String newType = newTransaction['type'];
      int newAccountId = newTransaction['account_id'];

      List<Map<String, dynamic>> newAccountResult = await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [newAccountId],
      );

      if (newAccountResult.isNotEmpty) {
        double currentBalance = newAccountResult.first['balance'];
        double balanceAfterApply;
        if (newType == 'income') {
          balanceAfterApply = currentBalance + newAmount;
        } else {
          balanceAfterApply = currentBalance - newAmount;
        }
        await txn.update(
          'accounts',
          {'balance': balanceAfterApply},
          where: 'id = ?',
          whereArgs: [newAccountId],
        );
      }

      // Cập nhật bản ghi giao dịch
      await txn.update(
        'transactions',
        newTransaction,
        where: 'id = ?',
        whereArgs: [newTransaction['id']],
      );
    });
    return 1; // Chỉ ra thành công
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await database;

    // Khi xóa một giao dịch, cũng hoàn tác ảnh hưởng của nó lên số dư tài khoản
    await db.transaction((txn) async {
      // Lấy chi tiết giao dịch trước khi xóa
      List<Map<String, dynamic>> transactionResult = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (transactionResult.isNotEmpty) {
        Map<String, dynamic> transaction = transactionResult.first;
        double amount = transaction['amount'];
        String type = transaction['type'];
        int accountId = transaction['account_id'];

        // Lấy số dư tài khoản hiện tại
        List<Map<String, dynamic>> accountResult = await txn.query(
          'accounts',
          where: 'id = ?',
          whereArgs: [accountId],
        );

        if (accountResult.isNotEmpty) {
          double currentBalance = accountResult.first['balance'];
          double newBalance;
          if (type == 'income') {
            newBalance = currentBalance - amount;
          } else {
            newBalance = currentBalance + amount;
          }

          await txn.update(
            'accounts',
            {'balance': newBalance},
            where: 'id = ?',
            whereArgs: [accountId],
          );
        }
      }
      // Xóa giao dịch
      await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
    });
    return 1; // Chỉ ra thành công
  }

  // Đóng database
  Future<void> close() async {
    Database db = await database;
    await db.close();
    _database = null; // Xóa instance khi đóng
  }

  // --- Phương thức chèn dữ liệu mẫu ---
  Future<void> insertInitialSampleData(int userId) async {
    Database db = await database;

    // Kiểm tra xem đã có dữ liệu mẫu chưa để tránh chèn lại
    List<Map<String, dynamic>> existingAccounts = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (existingAccounts.isNotEmpty) {
      print(
        'Dữ liệu mẫu đã tồn tại cho người dùng $userId. Bỏ qua chèn dữ liệu mẫu.',
      );
      return;
    }

    print('Bắt đầu chèn dữ liệu mẫu cho người dùng $userId...');
    final String currentTime = DateTime.now().toIso8601String();

    // Chèn tài khoản mẫu
    int mainWalletId = await insertAccount({
      'user_id': userId,
      'name': 'Ví chính',
      'balance': 1000000.0, // Số dư ban đầu
      'currency': 'VND',
      'created_at': currentTime,
    });
    int bankAccountId = await insertAccount({
      'user_id': userId,
      'name': 'Tài khoản ngân hàng',
      'balance': 5000000.0,
      'currency': 'VND',
      'created_at': currentTime,
    });
    print(
      'Đã chèn tài khoản mẫu: Ví chính (ID: $mainWalletId), Tài khoản ngân hàng (ID: $bankAccountId)',
    );

    // Chèn danh mục mẫu
    int foodCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Ăn uống',
      'type': 'expense',
      'icon': 'food_icon', // Tên icon giả định
      'created_at': currentTime,
    });
    int shoppingCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Mua sắm',
      'type': 'expense',
      'icon': 'shopping_icon',
      'created_at': currentTime,
    });
    int entertainmentCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Giải trí',
      'type': 'expense',
      'icon': 'entertainment_icon',
      'created_at': currentTime,
    });
    int transportationCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Đi lại',
      'type': 'expense',
      'icon': 'transport_icon',
      'created_at': currentTime,
    });
    int billsCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Hóa đơn',
      'type': 'expense',
      'icon': 'bills_icon',
      'created_at': currentTime,
    });
    int salaryCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Lương',
      'type': 'income',
      'icon': 'salary_icon',
      'created_at': currentTime,
    });
    int bonusCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Thưởng',
      'type': 'income',
      'icon': 'bonus_icon',
      'created_at': currentTime,
    });
    int otherIncomeCategoryId = await insertCategory({
      'user_id': userId,
      'name': 'Thu nhập khác',
      'type': 'income',
      'icon': 'other_income_icon',
      'created_at': currentTime,
    });
    print('Đã chèn danh mục mẫu.');

    // Chèn giao dịch mẫu
    // Lấy ngày hiện tại và các ngày gần đây
    String today = DateTime.now().toIso8601String();
    String yesterday =
        DateTime.now().subtract(Duration(days: 1)).toIso8601String();
    String twoDaysAgo =
        DateTime.now().subtract(Duration(days: 2)).toIso8601String();
    String threeDaysAgo =
        DateTime.now().subtract(Duration(days: 3)).toIso8601String();
    String lastWeek =
        DateTime.now().subtract(Duration(days: 7)).toIso8601String();

    await insertTransaction({
      'user_id': userId,
      'type': 'expense',
      'category_id': foodCategoryId,
      'amount': 50000.0,
      'description': 'Bữa trưa tại nhà hàng',
      'transaction_date': today,
      'payment_method': 'Tiền mặt',
      'account_id': mainWalletId,
      'created_at': currentTime,
    });

    await insertTransaction({
      'user_id': userId,
      'type': 'income',
      'category_id': salaryCategoryId,
      'amount': 1000000.0,
      'description': 'Nhận lương tháng 5',
      'transaction_date': yesterday,
      'payment_method': 'Chuyển khoản',
      'account_id': bankAccountId,
      'created_at': currentTime,
    });

    await insertTransaction({
      'user_id': userId,
      'type': 'expense',
      'category_id': shoppingCategoryId,
      'amount': 250000.0,
      'description': 'Mua sắm quần áo',
      'transaction_date': twoDaysAgo,
      'payment_method': 'Thẻ tín dụng',
      'account_id': bankAccountId,
      'created_at': currentTime,
    });

    await insertTransaction({
      'user_id': userId,
      'type': 'expense',
      'category_id': transportationCategoryId,
      'amount': 20000.0,
      'description': 'Tiền xăng xe',
      'transaction_date': threeDaysAgo,
      'payment_method': 'Tiền mặt',
      'account_id': mainWalletId,
      'created_at': currentTime,
    });

    await insertTransaction({
      'user_id': userId,
      'type': 'income',
      'category_id': bonusCategoryId,
      'amount': 200000.0,
      'description': 'Tiền thưởng dự án',
      'transaction_date': lastWeek,
      'payment_method': 'Chuyển khoản',
      'account_id': bankAccountId,
      'created_at': currentTime,
    });

    print('Đã chèn giao dịch mẫu.');
    print('Hoàn tất chèn dữ liệu mẫu.');
  }
}
