class Category {
  int? id;
  int userId;
  String name;
  String type; // 'income' or 'expense'
  String? icon; // Tên icon hoặc path
  String createdAt; // Thêm trường này

  Category({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    required this.createdAt, // Thêm vào constructor
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      createdAt: map['created_at'], // Thêm vào fromMap
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'created_at': createdAt, // Thêm vào toMap
    };
  }

  // MỚI: Phương thức toMapWithoutId
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
