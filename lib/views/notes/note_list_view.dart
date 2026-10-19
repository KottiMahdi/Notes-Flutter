import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/note_controller.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/widgets/retry_snack_bar.dart';
import '../../core/utils/screen_cache.dart';
import '../../core/widgets/loading_view.dart';
import '../../models/category_model.dart';
import '../../models/categorized_note_model.dart';
import '../home/widgets/success_dialog.dart';
import 'add_note_view.dart';
import 'edit_note_view.dart';
import 'widgets/delete_note_dialog.dart';
import 'widgets/note_list_app_bar.dart';
import 'widgets/note_list_bottom_nav.dart';
import 'widgets/note_list_scroll_view.dart';
import 'widgets/notes_load_error_view.dart';

const _kPrimaryOrange = Color(0xFFF59E0B);

class NoteListView extends StatefulWidget {
  /// When null, the screen aggregates notes across every category owned by
  /// the current user ("All Notes"). When set, it scopes to one category.
  final String? categoryId;
  final String? categoryName;
  final NoteController? noteController;
  final CategoryController? categoryController;
  final AuthController? authController;

  const NoteListView({
    super.key,
    this.categoryId,
    this.categoryName,
    this.noteController,
    this.categoryController,
    this.authController,
  });

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  late final NoteController _noteController =
      widget.noteController ?? NoteController();
  late final CategoryController _categoryController =
      widget.categoryController ?? CategoryController();
  late final AuthController _authController =
      widget.authController ?? AuthController();

  bool get _isAllNotesMode => widget.categoryId == null;

  // Only cache real (non-injected) data sources.
  bool get _useCache =>
      widget.noteController == null && widget.categoryController == null;
  String get _cacheKey => 'notes:${widget.categoryId ?? '*'}';

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isPreparingAdd = false;
  bool _sortNewestFirst = true;
  String? _loadError;
  String? _categoryTitle;
  List<CategoryModel> _categories = [];
  final Set<String> _deletingNoteIds = {};
  final Set<String> _openingNoteIds = {};
  List<CategorizedNoteModel> _entries = [];
  List<CategorizedNoteModel> _sortedEntries = [];
  List<CategorizedNoteModel> _uncategorizedEntries = [];
  List<CategorizedNoteModel> _categorizedEntries = [];

  void _rebuildSortedSections() {
    _sortedEntries = _sortNewestFirst ? _entries : _entries.reversed.toList();
    _uncategorizedEntries = [];
    _categorizedEntries = [];

    for (final entry in _sortedEntries) {
      if (entry.categoryName.trim().toLowerCase() == 'uncategorized') {
        _uncategorizedEntries.add(entry);
      } else {
        _categorizedEntries.add(entry);
      }
    }
  }

  Future<void> _fetchNotes({bool showLoading = false}) async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
        if (showLoading) {
          _isLoading = true;
          _loadError = null;
        }
      });
    }

    try {
      if (_isAllNotesMode) {
        final result = await _noteController.getAllNotes();
        final categories = result.categories;
        final entries = result.entries;
        if (!mounted) return;
        if (_useCache) {
          ScreenCache.write(_cacheKey, (categories, entries, null));
        }
        setState(() {
          _categories = categories;
          _entries = entries;
          _rebuildSortedSections();
          _isLoading = false;
          _isRefreshing = false;
          _loadError = null;
        });
      } else {
        final categoryId = widget.categoryId!;
        final categoryName = widget.categoryName ??
            (await _categoryController.getCategory(categoryId)).name;
        final notes = await _noteController.getNotes(categoryId);
        if (!mounted) return;
        final entries = notes
            .map((note) => CategorizedNoteModel(
                  note: note,
                  categoryId: categoryId,
                  categoryName: categoryName,
                ))
            .toList();
        if (_useCache) {
          ScreenCache.write(
              _cacheKey, (const <CategoryModel>[], entries, categoryName));
        }
        setState(() {
          _categoryTitle = categoryName;
          _entries = entries;
          _rebuildSortedSections();
          _isLoading = false;
          _isRefreshing = false;
          _loadError = null;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _loadError = AppErrorMessages.fromException(
          error,
          fallback: 'Could not load notes. Please try again.',
        );
      });
    }
  }

  Future<void> _openAddNote() async {
    if (_isPreparingAdd || _isLoading) return;
    setState(() => _isPreparingAdd = true);

    try {
      final navigator = Navigator.of(context);
      String? targetCategoryId = widget.categoryId;

      if (targetCategoryId == null) {
        try {
          final result = await _categoryController
              .getOrCreateUncategorizedCategory(_categories);
          targetCategoryId = result.category.id;
          if (!identical(result.categories, _categories) && mounted) {
            setState(() => _categories = result.categories);
          }
        } catch (error) {
          if (!mounted) return;
          showRetrySnackBar(
            context,
            message: AppErrorMessages.fromException(
              error,
              fallback: 'Could not prepare an uncategorized note.',
            ),
            onRetry: _openAddNote,
          );
          return;
        }
      }
      if (!mounted) return;

      final changed = await navigator.push(
        MaterialPageRoute(
          builder: (context) => AddNoteView(categoryId: targetCategoryId!),
        ),
      );
      if (!mounted) return;
      if (changed == true) {
        await _fetchNotes();
        if (!mounted) return;
        await showSuccessDialog(
          context: context,
          title: 'Note added',
          message: 'Your note has been saved.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPreparingAdd = false);
      }
    }
  }

  Future<void> _openEditNote(CategorizedNoteModel entry) async {
    final noteId = entry.note.id;
    if (!_openingNoteIds.add(noteId)) return;
    try {
      final changed = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditNoteView(
            categoryId: entry.categoryId,
            noteId: noteId,
            oldText: entry.note.note,
            oldTitle: entry.note.title,
          ),
        ),
      );
      if (!mounted) return;
      if (changed == true) {
        await _fetchNotes();
        if (!mounted) return;
        await showSuccessDialog(
          context: context,
          title: 'Note updated',
          message: 'Your changes have been saved.',
        );
      }
    } finally {
      _openingNoteIds.remove(noteId);
    }
  }

  Future<void> _deleteNote(CategorizedNoteModel entry) async {
    if (_deletingNoteIds.contains(entry.note.id)) return;

    setState(() => _deletingNoteIds.add(entry.note.id));
    try {
      await _noteController.deleteNote(entry.categoryId, entry.note.id);
      if (!mounted) return;
      await _fetchNotes();
      if (!mounted) return;
      await showSuccessDialog(
        context: context,
        title: 'Note deleted',
        message: 'The note has been removed.',
      );
    } catch (error) {
      if (!mounted) return;
      showRetrySnackBar(
        context,
        message: AppErrorMessages.fromException(
          error,
          fallback: 'Could not delete the note. Please try again.',
        ),
        onRetry: () => _deleteNote(entry),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingNoteIds.remove(entry.note.id));
      }
    }
  }

  Future<void> _confirmDeleteNote(CategorizedNoteModel entry) async {
    final confirmed = await DeleteNoteDialog.show(context);
    if (confirmed == true && mounted) {
      await _deleteNote(entry);
    }
  }

  void _goToCategories() {
    Navigator.of(context).pushNamedAndRemoveUntil('homepage', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    if (_useCache) {
      final cached = ScreenCache.read<
          (
            List<CategoryModel>,
            List<CategorizedNoteModel>,
            String?
          )>(_cacheKey);
      if (cached != null) {
        _categories = cached.$1;
        _entries = cached.$2;
        _rebuildSortedSections();
        _categoryTitle = cached.$3;
        _isLoading = false;
      }
    }
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_isAllNotesMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !_isAllNotesMode) return;
        _goToCategories();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFFFFCF7),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: SizedBox(
            height: 54,
            child: FloatingActionButton(
              tooltip: 'Add note',
              backgroundColor: _kPrimaryOrange,
              foregroundColor: const Color(0xFF17202A),
              onPressed: _isLoading || _isPreparingAdd ? null : _openAddNote,
              child: _isPreparingAdd
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF17202A),
                      ),
                    )
                  : const Icon(Icons.add_circle_outline, size: 28),
            ),
          ),
        ),
        appBar: NoteListAppBar(
          isAllNotesMode: _isAllNotesMode,
          title: _isAllNotesMode ? 'All Notes' : (_categoryTitle ?? 'Notes'),
          noteCount: _entries.length,
        ),
        body: SafeArea(
          top: false,
          child: _isLoading
              ? const LoadingView(message: 'Loading notes')
              : _loadError != null
                  ? NotesLoadErrorView(
                      message: _loadError!,
                      onRetry: () => _fetchNotes(showLoading: true),
                    )
                  : Column(
                      children: [
                        if (_isRefreshing)
                          const LinearProgressIndicator(
                            minHeight: 2,
                            semanticsLabel: 'Refreshing notes',
                          ),
                        Expanded(
                          child: NoteListScrollView(
                            isDark: isDark,
                            isAllNotesMode: _isAllNotesMode,
                            entries: _sortedEntries,
                            uncategorizedEntries: _uncategorizedEntries,
                            categorizedEntries: _categorizedEntries,
                            deletingNoteIds: _deletingNoteIds,
                            sortNewestFirst: _sortNewestFirst,
                            onToggleSort: () {
                              setState(() {
                                _sortNewestFirst = !_sortNewestFirst;
                                _rebuildSortedSections();
                              });
                            },
                            onNoteTap: _openEditNote,
                            onNoteLongPress: _confirmDeleteNote,
                            onAddNote: _isPreparingAdd ? null : _openAddNote,
                          ),
                        ),
                      ],
                    ),
        ),
        bottomNavigationBar: _isAllNotesMode
            ? NoteListBottomNav(
                isDark: isDark,
                authController: _authController,
                onGoToCategories: _goToCategories,
              )
            : null,
      ),
    );
  }
}
