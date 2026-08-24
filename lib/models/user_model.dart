class UserModel {
  final String username;
  final String email;
  final String? uid;

  UserModel({
    required this.username,
    required this.email,
    this.uid,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      username: map['Username'] ?? map['username'] ?? '',
      email: map['Email'] ?? map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'Username': username,
      'Email': email,
    };
  }
}
