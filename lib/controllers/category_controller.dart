import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category_model.dart';

class CategoryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Fetch categories for the current user ───────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('categories')
        .where('id', isEqualTo: uid)
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ── Add a new category ─────────────────────────────────────────────────────
  Future<void> addCategory(String name) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('categories').add({'name': name, 'id': uid});
  }

  // ── Update a category's name ───────────────────────────────────────────────
  Future<void> updateCategory(String docId, String newName) async {
    await _firestore
        .collection('categories')
        .doc(docId)
        .update({'name': newName});
  }

  // ── Delete a category ──────────────────────────────────────────────────────
  Future<void> deleteCategory(String docId) async {
    await _firestore.collection('categories').doc(docId).delete();
  }
}
