import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category_model.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';

class CategoryController {
  final AuthService _authService;
  final CategoryService _categoryService;

  CategoryController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AuthService? authService,
    CategoryService? categoryService,
  })  : _authService = authService ?? AuthService(auth: auth),
        _categoryService =
            categoryService ?? CategoryService(firestore: firestore);

  Future<void> _ensureCategoryOwnership(String docId) async {
    final uid = _authService.requireCurrentUser().uid;

    final category = await _categoryService.getCategory(docId);
    if (category == null || category.userId != uid) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'You are not authorized to access this category.',
      );
    }
  }

  // ── Fetch categories for the current user ───────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    final uid = _authService.requireCurrentUser().uid;
    return _categoryService.getCategories(uid);
  }

  Future<int> getNoteCount(String categoryId) async {
    await _ensureCategoryOwnership(categoryId);
    return _categoryService.getNoteCount(
      categoryId,
      _authService.requireCurrentUser().uid,
    );
  }

  // ── Fetch a single category owned by the current user ───────────────────────
  Future<CategoryModel> getCategory(String docId) async {
    await _ensureCategoryOwnership(docId);

    return (await _categoryService.getCategory(docId))!;
  }

  // ── Add a new category ─────────────────────────────────────────────────────
  Future<void> addCategory(
    String name, {
    int iconCode = 0xe2c8,
    int accentColor = 0xFFF59E0B,
    String type = 'Personal',
  }) async {
    final uid = _authService.requireCurrentUser().uid;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty.');
    }

    await _categoryService.addCategory(
      uid: uid,
      name: trimmedName,
      iconCode: iconCode,
      accentColor: accentColor,
      type: type,
    );
  }

  Future<
      ({
        CategoryModel category,
        List<CategoryModel> categories,
      })> getOrCreateUncategorizedCategory(List<CategoryModel> categories) async {
    for (final category in categories) {
      if (category.name.trim().toLowerCase() == 'uncategorized') {
        return (category: category, categories: categories);
      }
    }

    await addCategory('Uncategorized');
    final updatedCategories = await getCategories();
    for (final category in updatedCategories) {
      if (category.name.trim().toLowerCase() == 'uncategorized') {
        return (category: category, categories: updatedCategories);
      }
    }
    throw StateError('The Uncategorized category could not be found.');
  }

  // ── Update a category's name ───────────────────────────────────────────────
  Future<void> updateCategory(
    String docId,
    String newName, {
    int? iconCode,
    int? accentColor,
    String? type,
  }) async {
    final uid = _authService.requireCurrentUser().uid;
    await _ensureCategoryOwnership(docId);

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
          newName, 'newName', 'Category name cannot be empty.');
    }

    await _categoryService.updateCategory(
      categoryId: docId,
      uid: uid,
      name: trimmedName,
      iconCode: iconCode,
      accentColor: accentColor,
      type: type,
    );
  }

  // ── Delete a category ──────────────────────────────────────────────────────
  Future<void> deleteCategory(String docId) async {
    _authService.requireCurrentUser();
    await _ensureCategoryOwnership(docId);

    await _categoryService.deleteCategory(docId);
  }
}
