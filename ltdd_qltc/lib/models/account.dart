import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final double balance;
  final String currency;
  final String createdAt;

  const Account({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  // SỬA LỖI: Thêm props để Equatable biết cách so sánh
  @override
  List<Object?> get props => [id, userId, name, balance, currency, createdAt];

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
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
