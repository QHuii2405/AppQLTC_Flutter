class User {
  int? id;
  String email;
  String password;
  String name;
  String createdAt;
  String? resetToken;
  int? resetTokenExpires;
  String? profileImageUrl; // Thêm trường này cho ảnh đại diện

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    this.resetToken,
    this.resetTokenExpires,
    this.profileImageUrl,
  });

  // Chuyển đổi từ Map (từ database) sang đối tượng User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      createdAt: map['created_at'],
      resetToken: map['reset_token'],
      resetTokenExpires: map['reset_token_expires'],
      profileImageUrl: map['profile_image_url'],
    );
  }

  // Chuyển đổi từ đối tượng User sang Map (để lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'created_at': createdAt,
      'reset_token': resetToken,
      'reset_token_expires': resetTokenExpires,
      'profile_image_url': profileImageUrl,
    };
  }

  // Phương thức để cập nhật thông tin người dùng
  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    String? createdAt,
    String? resetToken,
    int? resetTokenExpires,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      resetToken: resetToken ?? this.resetToken,
      resetTokenExpires: resetTokenExpires ?? this.resetTokenExpires,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
