import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final String type; // 'income' or 'expense'
  final String? icon;
  final String createdAt;

  const Category({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    required this.createdAt,
  });

  // SỬA LỖI: Thêm props để Equatable biết cách so sánh
  @override
  List<Object?> get props => [id, userId, name, type, icon, createdAt];

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'created_at': createdAt,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'created_at': createdAt,
    };
  }

  Category copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    String? icon,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
