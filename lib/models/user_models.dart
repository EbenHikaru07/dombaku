class UserModel {
  final String uid;
  final String email;
  final String username;
  final String status;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.status,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      status: map['status'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
