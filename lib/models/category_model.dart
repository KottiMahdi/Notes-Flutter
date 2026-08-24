class CategoryModel {
  final String id;
  final String name;
  final String userId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.userId,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      userId: map['userId'] ?? map['uid'] ?? map['id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
    };
  }
}
