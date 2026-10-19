import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/error/guarded_call.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore;

  CategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  Future<List<CategoryModel>> getCategories(String uid) =>
      guardedCall(() async {
        final snapshot =
            await _categories.where('userId', isEqualTo: uid).get();
        return snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
            .toList();
      });

  Future<int> getNoteCount(String categoryId, String uid) =>
      guardedCall(() async {
        final snapshot = await _categories
            .doc(categoryId)
            .collection('note')
            .where('userId', isEqualTo: uid)
            .get();
        return snapshot.size;
      });

  Future<CategoryModel?> getCategory(String categoryId) =>
      guardedCall(() async {
        final doc = await _categories.doc(categoryId).get();
        final data = doc.data();
        return doc.exists && data != null
            ? CategoryModel.fromMap(doc.id, data)
            : null;
      });

  Future<void> addCategory({
    required String uid,
    required String name,
    required int iconCode,
    required int accentColor,
    required String type,
  }) {
    return guardedCall(
      isWrite: true,
      () => _categories.add({
        'name': name,
        'userId': uid,
        'iconCode': iconCode,
        'accentColor': accentColor,
        'type': type,
      }),
    );
  }

  Future<void> updateCategory({
    required String categoryId,
    required String uid,
    required String name,
    int? iconCode,
    int? accentColor,
    String? type,
  }) {
    final updates = <String, dynamic>{
      'name': name,
      'userId': uid,
    };
    if (iconCode != null) updates['iconCode'] = iconCode;
    if (accentColor != null) updates['accentColor'] = accentColor;
    if (type != null) updates['type'] = type;
    return guardedCall(
      isWrite: true,
      () => _categories.doc(categoryId).update(updates),
    );
  }

  Future<void> deleteCategory(String categoryId) {
    return guardedCall(
      isWrite: true,
      () => _categories.doc(categoryId).delete(),
    );
  }
}
