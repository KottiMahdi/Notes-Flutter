import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_model.dart';

class NoteController {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NoteController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? _ownerUid(Map<String, dynamic>? data) {
    if (data == null) return null;
    final value = data['userId'] ?? data['uid'] ?? data['id'];
    return value is String ? value : null;
  }

  DocumentReference<Map<String, dynamic>> _categoryDoc(String categoryId) {
    return _firestore.collection('categories').doc(categoryId);
  }

  CollectionReference<Map<String, dynamic>> _noteCollection(String categoryId) {
    return _categoryDoc(categoryId).collection('note');
  }

  Future<void> _requireCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no authenticated user.',
      );
    }
  }

  Future<void> _ensureCategoryOwnership(String categoryId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no authenticated user.',
      );
    }

    final categoryDoc = await _categoryDoc(categoryId).get();
    if (!categoryDoc.exists || _ownerUid(categoryDoc.data()) != uid) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'You are not authorized to access this category.',
      );
    }
  }

  Future<void> _ensureNoteOwnership(String categoryId, String noteId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no authenticated user.',
      );
    }

    await _ensureCategoryOwnership(categoryId);

    final noteDoc = await _noteCollection(categoryId).doc(noteId).get();
    if (!noteDoc.exists || _ownerUid(noteDoc.data()) != uid) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'You are not authorized to access this note.',
      );
    }
  }

  // ── Fetch notes for a category ─────────────────────────────────────────────
  Future<List<NoteModel>> getNotes(String categoryId) async {
    await _requireCurrentUser();
    await _ensureCategoryOwnership(categoryId);

    final snapshot = await _noteCollection(categoryId)
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();
    return snapshot.docs
        .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ── Add a note ────────────────────────────────────────────────────────────
  Future<void> addNote(String categoryId, String noteText) async {
    await _requireCurrentUser();
    await _ensureCategoryOwnership(categoryId);

    final trimmed = noteText.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
          noteText, 'noteText', 'Note text cannot be empty.');
    }

    await _noteCollection(categoryId)
        .add({'note': trimmed, 'userId': _auth.currentUser!.uid});
  }

  // ── Update a note ─────────────────────────────────────────────────────────
  Future<void> editNote(
      String categoryId, String noteId, String newText) async {
    await _requireCurrentUser();
    await _ensureNoteOwnership(categoryId, noteId);

    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
          newText, 'newText', 'Note text cannot be empty.');
    }

    await _noteCollection(categoryId).doc(noteId).update({
      'note': trimmed,
      'userId': _auth.currentUser!.uid,
    });
  }

  // ── Delete a note ─────────────────────────────────────────────────────────
  Future<void> deleteNote(String categoryId, String noteId) async {
    await _requireCurrentUser();
    await _ensureNoteOwnership(categoryId, noteId);

    await _noteCollection(categoryId).doc(noteId).delete();
  }
}
