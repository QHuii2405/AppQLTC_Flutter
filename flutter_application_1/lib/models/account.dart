class Account {
  int? id;
  int userId;
  String name;
  double balance;
  String currency;
  String createdAt; // Thêm trường này

  Account({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt, // Thêm vào constructor
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      balance: map['balance'],
      currency: map['currency'],
      createdAt: map['created_at'], // Thêm vào fromMap
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt, // Thêm vào toMap
    };
  }
}
