import 'package:sqflite/sqflite.dart'
    as sqflite_api; // Đổi tên import để tránh xung đột
import 'package:path/path.dart';
import 'dart:math'; // Dùng để tạo số ngẫu nhiên cho token
import 'package:intl/intl.dart'; // Để định dạng ngày tháng

// Import các Model classes
import 'package:flutter_application_1/models/user.dart'; // Thay thế bằng đường dẫn thực tế của bạn
import 'package:flutter_application_1/models/account.dart'; // Thay thế bằng đường dẫn thực tế của bạn
import 'package:flutter_application_1/models/category.dart'; // Thay thế bằng đường dẫn thực tế của bạn
import 'package:flutter_application_1/models/transaction.dart'; // Thay thế bằng đường dẫn thực tế của bạn

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static sqflite_api.Database? _database; // Sử dụng prefix cho Database

  Future<sqflite_api.Database> get database async {
    // Sử dụng prefix cho Database
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqflite_api.Database> _initDatabase() async {
    // Sử dụng prefix cho Database
    String path = join(
      await sqflite_api.getDatabasesPath(),
      'ewallet.db',
    ); // Đã sửa lỗi tại đây
    return await sqflite_api.openDatabase(
      // Sử dụng prefix cho openDatabase
      path,
      version:
          4, // Đảm bảo version được tăng lên nếu bạn thêm cột profile_image_url
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(sqflite_api.Database db, int version) async {
    // Sử dụng prefix cho Database
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        reset_token TEXT,
        reset_token_expires INTEGER,
        profile_image_url TEXT -- Cột ảnh đại diện đã được thêm
      )
    ''');

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

    // Chèn người dùng admin mặc định
    final String currentTime = DateTime.now().toIso8601String();
    await db.insert('users', {
      'email': 'admin@example.com',
      'password':
          'admin_password', // Trong ứng dụng thực tế, hãy mã hóa mật khẩu này!
      'name': 'Người dùng Admin',
      'created_at': currentTime,
      'profile_image_url': null, // Giá trị mặc định cho ảnh đại diện
    });

    print('Database đã được tạo và người dùng admin đã được chèn.');
  }

  Future _onUpgrade(
    sqflite_api.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Sử dụng prefix cho Database
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN reset_token TEXT');
      await db.execute(
        'ALTER TABLE users ADD COLUMN reset_token_expires INTEGER',
      );
      print(
        'Đã nâng cấp lên version 2: Đã thêm cột reset_token vào bảng users.',
      );
    }
    if (oldVersion < 3) {
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
    if (oldVersion < 4) {
      // Nâng cấp lên version 4 để thêm cột profile_image_url
      await db.execute('ALTER TABLE users ADD COLUMN profile_image_url TEXT');
      print(
        'Đã nâng cấp lên version 4: Đã thêm cột profile_image_url vào bảng users.',
      );
    }
  }

  // --- Phương thức quản lý người dùng ---

  Future<int> insertUser(User user) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(int id) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<bool> checkEmailExists(String email) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  Future<int> updateUser(User user) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<String?> createResetToken(String email) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isEmpty) {
      return null;
    }
    String resetToken = _generateResetToken();
    int expiresAt =
        DateTime.now().add(Duration(minutes: 15)).millisecondsSinceEpoch;
    await db.update(
      'users',
      {'reset_token': resetToken, 'reset_token_expires': expiresAt},
      where: 'email = ?',
      whereArgs: [email],
    );
    return resetToken;
  }

  Future<bool> verifyResetToken(String email, String token) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND reset_token = ?',
      whereArgs: [email, token],
    );
    if (results.isEmpty) {
      return false;
    }
    int? expiresAt = results.first['reset_token_expires'];
    if (expiresAt == null ||
        DateTime.now().millisecondsSinceEpoch > expiresAt) {
      return false;
    }
    return true;
  }

  Future<bool> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    if (!await verifyResetToken(email, token)) {
      return false;
    }
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

  String _generateResetToken() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  Future<void> cleanExpiredTokens() async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'users',
      {'reset_token': null, 'reset_token_expires': null},
      where: 'reset_token_expires < ?',
      whereArgs: [currentTime],
    );
  }

  // --- Phương thức quản lý tài khoản ---

  Future<int> insertAccount(Account account) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAccounts(int userId) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<Account?> getAccountById(int accountId) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAccount(Account account) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // --- Phương thức quản lý danh mục ---

  Future<int> insertCategory(Category category) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories(int userId) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int categoryId) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(Category category) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Phương thức quản lý giao dịch ---

  Future<int> insertTransaction(Transaction transaction) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    await db.transaction((txn) async {
      // Sử dụng prefix cho transaction
      int transactionId = await txn.insert('transactions', transaction.toMap());

      Account? account = await getAccountById(transaction.accountId);
      if (account != null) {
        double newBalance;
        if (transaction.type == 'income') {
          newBalance = account.balance + transaction.amount;
        } else {
          newBalance = account.balance - transaction.amount;
        }
        await txn.update(
          'accounts',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [account.id],
        );
      }
      return transactionId;
    });
    return 1;
  }

  Future<List<Transaction>> getTransactions(int userId) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    // Sử dụng JOIN để lấy tên danh mục và tên tài khoản
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        t.*, 
        c.name AS category_name, 
        c.icon AS category_icon,
        a.name AS account_name
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      JOIN accounts a ON t.account_id = a.id
      WHERE t.user_id = ?
      ORDER BY t.transaction_date DESC
    ''',
      [userId],
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database

    await db.transaction((txn) async {
      // Sử dụng prefix cho transaction
      // Hoàn tác ảnh hưởng của giao dịch cũ lên số dư tài khoản
      Account? oldAccount = await getAccountById(oldTransaction.accountId);
      if (oldAccount != null) {
        double balanceAfterRevert;
        if (oldTransaction.type == 'income') {
          balanceAfterRevert = oldAccount.balance - oldTransaction.amount;
        } else {
          balanceAfterRevert = oldAccount.balance + oldTransaction.amount;
        }
        await txn.update(
          'accounts',
          {'balance': balanceAfterRevert},
          where: 'id = ?',
          whereArgs: [oldAccount.id],
        );
      }

      // Áp dụng ảnh hưởng của giao dịch mới lên số dư tài khoản
      Account? newAccount = await getAccountById(newTransaction.accountId);
      if (newAccount != null) {
        double balanceAfterApply;
        if (newTransaction.type == 'income') {
          balanceAfterApply = newAccount.balance + newTransaction.amount;
        } else {
          balanceAfterApply = newAccount.balance - newTransaction.amount;
        }
        await txn.update(
          'accounts',
          {'balance': balanceAfterApply}, // Đã sửa lỗi ở đây
          where: 'id = ?',
          whereArgs: [newAccount.id],
        );
      }

      // Cập nhật bản ghi giao dịch
      await txn.update(
        'transactions',
        newTransaction.toMap(),
        where: 'id = ?',
        whereArgs: [newTransaction.id],
      );
    });
    return 1;
  }

  Future<int> deleteTransaction(int id) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database

    await db.transaction((txn) async {
      // Sử dụng prefix cho transaction
      // Lấy chi tiết giao dịch trước khi xóa để hoàn tác số dư tài khoản
      final List<Map<String, dynamic>> transactionResult = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (transactionResult.isNotEmpty) {
        final Transaction transactionToDelete = Transaction.fromMap(
          transactionResult.first,
        );
        Account? account = await getAccountById(transactionToDelete.accountId);

        if (account != null) {
          double newBalance;
          if (transactionToDelete.type == 'income') {
            newBalance = account.balance - transactionToDelete.amount;
          } else {
            newBalance = account.balance + transactionToDelete.amount;
          }

          await txn.update(
            'accounts',
            {'balance': newBalance},
            where: 'id = ?',
            whereArgs: [account.id],
          );
        }
      }
      // Xóa giao dịch
      await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
    });
    return 1;
  }

  // Phương thức chèn dữ liệu mẫu ban đầu
  Future<void> insertInitialSampleData(int userId) async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database

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
    Account mainWallet = Account(
      userId: userId,
      name: 'Ví chính',
      balance: 1000000.0,
      currency: 'VND',
      createdAt: currentTime,
    );
    int mainWalletId = await insertAccount(mainWallet);
    Account bankAccount = Account(
      userId: userId,
      name: 'Tài khoản ngân hàng',
      balance: 5000000.0,
      currency: 'VND',
      createdAt: currentTime,
    );
    int bankAccountId = await insertAccount(bankAccount);
    print(
      'Đã chèn tài khoản mẫu: Ví chính (ID: $mainWalletId), Tài khoản ngân hàng (ID: $bankAccountId)',
    );

    // Chèn danh mục mẫu
    Category foodCategory = Category(
      userId: userId,
      name: 'Ăn uống',
      type: 'expense',
      icon: '🍽️',
      createdAt: currentTime,
    );
    int foodCategoryId = await insertCategory(foodCategory);
    Category shoppingCategory = Category(
      userId: userId,
      name: 'Mua sắm',
      type: 'expense',
      icon: '🛍️',
      createdAt: currentTime,
    );
    int shoppingCategoryId = await insertCategory(shoppingCategory);
    Category entertainmentCategory = Category(
      userId: userId,
      name: 'Giải trí',
      type: 'expense',
      icon: '🏖️',
      createdAt: currentTime,
    );
    int entertainmentCategoryId = await insertCategory(entertainmentCategory);
    Category transportationCategory = Category(
      userId: userId,
      name: 'Di chuyển',
      type: 'expense',
      icon: '🚗',
      createdAt: currentTime,
    );
    int transportationCategoryId = await insertCategory(transportationCategory);
    Category billsCategory = Category(
      userId: userId,
      name: 'Hóa đơn',
      type: 'expense',
      icon: '🧾',
      createdAt: currentTime,
    );
    int billsCategoryId = await insertCategory(billsCategory);
    Category salaryCategory = Category(
      userId: userId,
      name: 'Lương',
      type: 'income',
      icon: '💰',
      createdAt: currentTime,
    );
    int salaryCategoryId = await insertCategory(salaryCategory);
    Category bonusCategory = Category(
      userId: userId,
      name: 'Thưởng',
      type: 'income',
      icon: '🎁',
      createdAt: currentTime,
    );
    int bonusCategoryId = await insertCategory(bonusCategory);
    Category otherIncomeCategory = Category(
      userId: userId,
      name: 'Thu nhập khác',
      type: 'income',
      icon: '📈',
      createdAt: currentTime,
    );
    int otherIncomeCategoryId = await insertCategory(otherIncomeCategory);
    print('Đã chèn danh mục mẫu.');

    // Chèn giao dịch mẫu
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(Duration(days: 1)));
    String twoDaysAgo = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(Duration(days: 2)));
    String threeDaysAgo = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(Duration(days: 3)));
    String lastWeek = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(Duration(days: 7)));

    await insertTransaction(
      Transaction(
        userId: userId,
        type: 'expense',
        categoryId: foodCategoryId,
        amount: 50000.0,
        description: 'Bữa trưa tại nhà hàng',
        transactionDate: today,
        paymentMethod: 'Tiền mặt',
        accountId: mainWalletId,
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

  // Đóng database
  Future<void> close() async {
    sqflite_api.Database db = await database; // Sử dụng prefix cho Database
    await db.close();
    _database = null; // Xóa instance khi đóng
  }
}
