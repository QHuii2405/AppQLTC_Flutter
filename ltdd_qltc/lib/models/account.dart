class Account {
  int? id;
  int userId;
  String name;
  double balance;
  String currency;
  String createdAt;

  Account({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      // SỬA LỖI: Chuyển đổi tường minh sang double
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'user_id': userId,
      'name': name,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt,
    };
  }
}

extension AccountCopyWith on Account {
  Account copyWith({
    int? id,
    int? userId,
    String? name,
    double? balance,
    String? currency,
    String? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
