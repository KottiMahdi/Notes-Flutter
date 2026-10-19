import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';
import '../models/categorized_note_model.dart';
import '../models/note_model.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../services/note_service.dart';

class NoteController {
  static const _allNotesFetchBatchSize = 10;

  final AuthService _authService;
  final NoteService _noteService;
  final CategoryService _categoryService;

  NoteController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AuthService? authService,
    NoteService? noteService,
    CategoryService? categoryService,
  })  : _authService = authService ?? AuthService(auth: auth),
        _noteService = noteService ?? NoteService(firestore: firestore),
        _categoryService =
            categoryService ?? CategoryService(firestore: firestore);

  Future<void> _ensureCategoryOwnership(String categoryId) async {
    final uid = _authService.requireCurrentUser().uid;

    final ownerUid = await _noteService.getCategoryOwnerId(categoryId);
    if (ownerUid != uid) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
        message: 'You are not authorized to access this category.',
      );
    }
  }

  Future<void> _ensureNoteOwnership(String categoryId, String noteId) async {
    final uid = _authService.requireCurrentUser().uid;

    await _ensureCategoryOwnership(categoryId);

    final ownerUid = await _noteService.getNoteOwnerId(categoryId, noteId);
    if (ownerUid != uid) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
        message: 'You are not authorized to access this note.',
      );
    }
  }

  // ── Fetch notes for a category ─────────────────────────────────────────────
  Future<List<NoteModel>> getNotes(String categoryId) async {
    final uid = _authService.requireCurrentUser().uid;
    await _ensureCategoryOwnership(categoryId);

    final notes = await _noteService.getNotes(categoryId, uid);
    notes.sort((a, b) {
      final aCreatedAt = a.createdAt;
      final bCreatedAt = b.createdAt;
      if (aCreatedAt == null && bCreatedAt == null) return 0;
      if (aCreatedAt == null) return 1;
      if (bCreatedAt == null) return -1;
      return bCreatedAt.compareTo(aCreatedAt);
    });
    return notes;
  }

  Future<
      ({
        List<CategoryModel> categories,
        List<CategorizedNoteModel> entries,
      })> getAllNotes() async {
    final uid = _authService.requireCurrentUser().uid;
    final categories = await _categoryService.getCategories(uid);
    final entries = <CategorizedNoteModel>[];

    for (var offset = 0;
        offset < categories.length;
        offset += _allNotesFetchBatchSize) {
      final categoryBatch =
          categories.skip(offset).take(_allNotesFetchBatchSize);
      final categoryEntries = await Future.wait(
        categoryBatch.map((category) async {
          final notes = await getNotes(category.id);
          return notes
              .map(
                (note) => CategorizedNoteModel(
                  note: note,
                  categoryId: category.id,
                  categoryName: category.name,
                ),
              )
              .toList();
        }),
      );
      entries.addAll(categoryEntries.expand((items) => items));
    }
    entries.sort((a, b) {
      final aCreatedAt = a.note.createdAt;
      final bCreatedAt = b.note.createdAt;
      if (aCreatedAt == null && bCreatedAt == null) return 0;
      if (aCreatedAt == null) return 1;
      if (bCreatedAt == null) return -1;
      return bCreatedAt.compareTo(aCreatedAt);
    });

    return (categories: categories, entries: entries);
  }

  // ── Add a note ────────────────────────────────────────────────────────────
  Future<void> addNote(
    String categoryId,
    String noteText, {
    String title = '',
  }) async {
    final uid = _authService.requireCurrentUser().uid;
    await _ensureCategoryOwnership(categoryId);

    final trimmed = noteText.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
          noteText, 'noteText', 'Note text cannot be empty.');
    }

    await _noteService.addNote(
      categoryId: categoryId,
      note: trimmed,
      title: title.trim(),
      uid: uid,
    );
  }

  // ── Update a note ─────────────────────────────────────────────────────────
  Future<void> editNote(
    String categoryId,
    String noteId,
    String newText, {
    String title = '',
  }) async {
    final uid = _authService.requireCurrentUser().uid;
    await _ensureNoteOwnership(categoryId, noteId);

    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
          newText, 'newText', 'Note text cannot be empty.');
    }

    await _noteService.editNote(
      categoryId: categoryId,
      noteId: noteId,
      note: trimmed,
      title: title.trim(),
      uid: uid,
    );
  }

  // ── Delete a note ─────────────────────────────────────────────────────────
  Future<void> deleteNote(String categoryId, String noteId) async {
    _authService.requireCurrentUser();
    await _ensureNoteOwnership(categoryId, noteId);

    await _noteService.deleteNote(categoryId, noteId);
  }
}
