import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore;

  NoteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _category(String categoryId) =>
      _firestore.collection('categories').doc(categoryId);

  CollectionReference<Map<String, dynamic>> _notes(String categoryId) =>
      _category(categoryId).collection('note');

  Future<String?> getCategoryOwnerId(String categoryId) async {
    final category = await _category(categoryId).get();
    return _ownerUid(category.data());
  }

  Future<String?> getNoteOwnerId(String categoryId, String noteId) async {
    final note = await _notes(categoryId).doc(noteId).get();
    return _ownerUid(note.data());
  }

  Future<List<NoteModel>> getNotes(String categoryId, String uid) async {
    final snapshot =
        await _notes(categoryId).where('userId', isEqualTo: uid).get();
    return snapshot.docs
        .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addNote({
    required String categoryId,
    required String uid,
    required String note,
    required String title,
  }) {
    return _notes(categoryId).add({
      'note': note,
      'title': title,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editNote({
    required String categoryId,
    required String noteId,
    required String uid,
    required String note,
    required String title,
  }) {
    return _notes(categoryId).doc(noteId).update({
      'note': note,
      'title': title,
      'userId': uid,
    });
  }

  Future<void> deleteNote(String categoryId, String noteId) {
    return _notes(categoryId).doc(noteId).delete();
  }

  String? _ownerUid(Map<String, dynamic>? data) {
    if (data == null) return null;
    final value = data['userId'] ?? data['uid'] ?? data['id'];
    return value is String ? value : null;
  }
}
