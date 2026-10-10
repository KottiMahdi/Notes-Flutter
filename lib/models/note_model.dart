import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String note;
  final String title;
  final String userId;
  final DateTime? createdAt;

  NoteModel({
    required this.id,
    required this.note,
    required this.userId,
    this.title = '',
    this.createdAt,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    final rawCreatedAt = map['createdAt'];
    return NoteModel(
      id: id,
      note: map['note'] ?? '',
      title: map['title'] ?? '',
      userId: map['userId'] ?? map['uid'] ?? map['id'] ?? '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note': note,
      'title': title,
      'userId': userId,
    };
  }
}
