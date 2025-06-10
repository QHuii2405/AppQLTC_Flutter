class User {
  int? id;
  String email;
  String password;
  String name;
  String createdAt;
  String? resetToken;
  int? resetTokenExpires;
  String? profileImageUrl;
  String? dob;
  String? description;
  double?
  balance; // Tổng số dư từ tất cả các ví (không lưu trong DB, chỉ dùng cho hiển thị)

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    this.resetToken,
    this.resetTokenExpires,
    this.profileImageUrl,
    this.dob,
    this.description,
    this.balance,
  });

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
      dob: map['dob'],
      description: map['description'],
      balance: map['balance'],
    );
  }

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
      'dob': dob,
      'description': description,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'created_at': createdAt,
      'reset_token': resetToken,
      'reset_token_expires': resetTokenExpires,
      'profile_image_url': profileImageUrl,
      'dob': dob,
      'description': description,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    String? createdAt,
    String? resetToken,
    int? resetTokenExpires,
    String? profileImageUrl,
    String? dob,
    String? description,
    double? balance,
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
      dob: dob ?? this.dob,
      description: description ?? this.description,
      balance: balance ?? this.balance,
    );
  }
}
