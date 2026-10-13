class CategoryModel {
  final String id;
  final String name;
  final String userId;
  final int iconCode;
  final int accentColor;
  final String type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.userId,
    this.iconCode = 0xe2c8,
    this.accentColor = 0xFFF59E0B,
    this.type = 'Personal',
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      userId: map['userId'] ?? map['uid'] ?? map['id'] ?? '',
      iconCode: map['iconCode'] is int ? map['iconCode'] as int : 0xe2c8,
      accentColor:
          map['accentColor'] is int ? map['accentColor'] as int : 0xFFF59E0B,
      type: map['type'] is String ? map['type'] as String : 'Personal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'iconCode': iconCode,
      'accentColor': accentColor,
      'type': type,
    };
  }
}
