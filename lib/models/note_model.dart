class NoteModel {
  final String id;
  final String note;
  final String userId;

  NoteModel({
    required this.id,
    required this.note,
    required this.userId,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      note: map['note'] ?? '',
      userId: map['id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note': note,
      'id': userId,
    };
  }
}
