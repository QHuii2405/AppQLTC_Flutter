class Category {
  int? id;
  int userId;
  String name;
  String type; // 'income' or 'expense'
  String? icon;
  String createdAt;

  Category({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    required this.createdAt,
  });

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
}

extension CategoryCopyWith on Category {
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
