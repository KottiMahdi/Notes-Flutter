import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category_model.dart';

class CategoryController {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CategoryController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  String? _ownerUid(Map<String, dynamic>? data) {
    if (data == null) return null;
    final value = data['userId'] ?? data['uid'] ?? data['id'];
    return value is String ? value : null;
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

  Future<void> _ensureCategoryOwnership(String docId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no authenticated user.',
      );
    }

    final doc = await _categoriesRef.doc(docId).get();
    if (!doc.exists || _ownerUid(doc.data()) != uid) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'You are not authorized to access this category.',
      );
    }
  }

  // ── Fetch categories for the current user ───────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no authenticated user.',
      );
    }

    final snapshot = await _categoriesRef.where('userId', isEqualTo: uid).get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<int> getNoteCount(String categoryId) async {
    await _ensureCategoryOwnership(categoryId);
    final snapshot = await _categoriesRef
        .doc(categoryId)
        .collection('note')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();
    return snapshot.size;
  }

  // ── Fetch a single category owned by the current user ───────────────────────
  Future<CategoryModel> getCategory(String docId) async {
    await _requireCurrentUser();
    await _ensureCategoryOwnership(docId);

    final doc = await _categoriesRef.doc(docId).get();
    return CategoryModel.fromMap(doc.id, doc.data()!);
  }

  // ── Add a new category ─────────────────────────────────────────────────────
  Future<void> addCategory(
    String name, {
    int iconCode = 0xe2c8,
    int accentColor = 0xFFF59E0B,
    String type = 'Personal',
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no authenticated user.',
      );
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty.');
    }

    await _categoriesRef.add({
      'name': trimmedName,
      'userId': uid,
      'iconCode': iconCode,
      'accentColor': accentColor,
      'type': type,
    });
  }

  // ── Update a category's name ───────────────────────────────────────────────
  Future<void> updateCategory(
    String docId,
    String newName, {
    int? iconCode,
    int? accentColor,
    String? type,
  }) async {
    await _requireCurrentUser();
    await _ensureCategoryOwnership(docId);

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
          newName, 'newName', 'Category name cannot be empty.');
    }

    final updates = <String, dynamic>{
      'name': trimmedName,
      'userId': _auth.currentUser!.uid,
    };
    if (iconCode != null) updates['iconCode'] = iconCode;
    if (accentColor != null) updates['accentColor'] = accentColor;
    if (type != null) updates['type'] = type;

    await _categoriesRef.doc(docId).update(updates);
  }

  // ── Delete a category ──────────────────────────────────────────────────────
  Future<void> deleteCategory(String docId) async {
    await _requireCurrentUser();
    await _ensureCategoryOwnership(docId);

    await _categoriesRef.doc(docId).delete();
  }
}
