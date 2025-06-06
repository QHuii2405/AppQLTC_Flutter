class LoginHistory {
  int? id;
  int userId;
  String loginTime; // Thời gian đăng nhập (ISO 8601 string)
  String? deviceName; // Tên thiết bị (có thể null)

  LoginHistory({
    this.id,
    required this.userId,
    required this.loginTime,
    this.deviceName,
  });

  // Chuyển đổi từ Map (từ database) sang đối tượng LoginHistory
  factory LoginHistory.fromMap(Map<String, dynamic> map) {
    return LoginHistory(
      id: map['id'],
      userId: map['user_id'],
      loginTime: map['login_time'],
      deviceName: map['device_name'], // Đảm bảo đọc từ 'device_name'
    );
  }

  // Chuyển đổi từ đối tượng LoginHistory sang Map (để lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'login_time': loginTime,
      'device_name': deviceName, // Đảm bảo ghi vào 'device_name'
    };
  }

  // Phương thức để tạo Map mà không bao gồm 'id' (dùng khi insert)
  Map<String, dynamic> toMapWithoutId() {
    return {
      'user_id': userId,
      'login_time': loginTime,
      'device_name': deviceName,
    };
  }
}
