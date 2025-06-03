class Transaction {
  int? id;
  int userId;
  String type; // 'income' or 'expense'
  int categoryId;
  double amount;
  String? description;
  String transactionDate;
  String? paymentMethod;
  int accountId;
  String createdAt;

  // Thêm các trường để lưu trữ tên danh mục và tên tài khoản
  // Những trường này không có trong DB, mà được thêm vào khi lấy dữ liệu
  String? categoryName;
  String? accountName;
  String? categoryIcon;

  Transaction({
    this.id,
    required this.userId,
    required this.type,
    required this.categoryId,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.paymentMethod,
    required this.accountId,
    required this.createdAt,
    this.categoryName,
    this.accountName,
    this.categoryIcon,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      categoryId: map['category_id'],
      amount: map['amount'],
      description: map['description'],
      transactionDate: map['transaction_date'],
      paymentMethod: map['payment_method'],
      accountId: map['account_id'],
      createdAt: map['created_at'],
      // Các trường này sẽ được gán sau khi join dữ liệu từ DB
      categoryName: map['category_name'],
      accountName: map['account_name'],
      categoryIcon: map['category_icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate,
      'payment_method': paymentMethod,
      'account_id': accountId,
      'created_at': createdAt,
    };
  }
}
