class UserModel {
  final String username;
  final String email;

  UserModel({
    required this.username,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'Username': username,
      'Email': email,
    };
  }
}
