class User {
  int? id;
  String email;
  String password;
  String name;
  String createdAt;
  String? resetToken;
  int? resetTokenExpires;
  String? profileImageUrl;
  String? dob; // Thêm trường này
  String? description; // Thêm trường này

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    this.resetToken,
    this.resetTokenExpires,
    this.profileImageUrl,
    this.dob, // Cập nhật constructor
    this.description, // Cập nhật constructor
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
      dob: map['dob'], // Cập nhật fromMap
      description: map['description'], // Cập nhật fromMap
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
      'dob': dob, // Cập nhật toMap
      'description': description, // Cập nhật toMap
    };
  }
}
