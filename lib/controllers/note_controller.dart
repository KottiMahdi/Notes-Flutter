import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_model.dart';

class NoteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _noteCollection(String categoryId) {
    return _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('note');
  }

  // ── Fetch notes for a category ─────────────────────────────────────────────
  Future<List<NoteModel>> getNotes(String categoryId) async {
    final snapshot = await _noteCollection(categoryId).get();
    return snapshot.docs
        .map((doc) =>
            NoteModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ── Add a note ────────────────────────────────────────────────────────────
  Future<void> addNote(String categoryId, String noteText) async {
    final uid = _auth.currentUser!.uid;
    await _noteCollection(categoryId).add({'note': noteText, 'id': uid});
  }

  // ── Update a note ─────────────────────────────────────────────────────────
  Future<void> editNote(
      String categoryId, String noteId, String newText) async {
    final uid = _auth.currentUser!.uid;
    await _noteCollection(categoryId)
        .doc(noteId)
        .update({'note': newText, 'id': uid});
  }

  // ── Delete a note ─────────────────────────────────────────────────────────
  Future<void> deleteNote(String categoryId, String noteId) async {
    await _noteCollection(categoryId).doc(noteId).delete();
  }
}
