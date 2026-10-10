import 'dart:ui';

import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/note_controller.dart';
import '../../models/category_model.dart';
import '../../models/note_model.dart';
import '../../utils/app_error_messages.dart';
import '../../utils/note_content_codec.dart';
import '../../utils/screen_cache.dart';
import '../../utils/theme_mode_scope.dart';
import '../settings/settings_view.dart';
import '../home/widgets/success_dialog.dart';
import '../widgets/app_bottom_nav.dart';
import 'add_note_view.dart';
import 'edit_note_view.dart';

const _kPrimaryOrange = Color(0xFFF59E0B);
const _kDeepOrange = Color(0xFFC66A00);

/// A note paired with the category it belongs to, used so the aggregated
/// "All Notes" view can edit/delete notes that span multiple categories.
class _NoteEntry {
  final NoteModel note;
  final String categoryId;
  final String categoryName;

  const _NoteEntry({
    required this.note,
    required this.categoryId,
    required this.categoryName,
  });
}

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
  bool _sortNewestFirst = true;
  String? _loadError;
  String? _categoryTitle;
  List<CategoryModel> _categories = [];
  final Set<String> _deletingNoteIds = {};
  List<_NoteEntry> _entries = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<_NoteEntry> get _sortedEntries {
    if (_sortNewestFirst) return _entries;
    return _entries.reversed.toList();
  }

  List<_NoteEntry> get _uncategorizedEntries => _sortedEntries
      .where(
          (entry) => entry.categoryName.trim().toLowerCase() == 'uncategorized')
      .toList();

  List<_NoteEntry> get _categorizedEntries => _sortedEntries
      .where(
          (entry) => entry.categoryName.trim().toLowerCase() != 'uncategorized')
      .toList();

  Future<void> _fetchNotes({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      if (_isAllNotesMode) {
        final categories = await _categoryController.getCategories();
        final entries = <_NoteEntry>[];
        for (final category in categories) {
          final notes = await _noteController.getNotes(category.id);
          entries.addAll(notes.map((note) => _NoteEntry(
                note: note,
                categoryId: category.id,
                categoryName: category.name,
              )));
        }
        entries.sort((a, b) {
          final aCreatedAt = a.note.createdAt;
          final bCreatedAt = b.note.createdAt;
          if (aCreatedAt == null && bCreatedAt == null) return 0;
          if (aCreatedAt == null) return 1;
          if (bCreatedAt == null) return -1;
          return bCreatedAt.compareTo(aCreatedAt);
        });
        if (!mounted) return;
        if (_useCache) {
          ScreenCache.write(_cacheKey, (categories, entries, null));
        }
        setState(() {
          _categories = categories;
          _entries = entries;
          _isLoading = false;
          _loadError = null;
        });
      } else {
        final categoryId = widget.categoryId!;
        final categoryName = widget.categoryName ??
            await _categoryController
                .getCategory(categoryId)
                .then((category) => category.name)
                .catchError((_) => 'Workspace');
        final notes = await _noteController.getNotes(categoryId);
        if (!mounted) return;
        final entries = notes
            .map((note) => _NoteEntry(
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
          _isLoading = false;
          _loadError = null;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = AppErrorMessages.fromException(
          error,
          fallback: 'Could not load notes. Please try again.',
        );
      });
    }
  }

  Future<void> _openAddNote() async {
    final navigator = Navigator.of(context);
    String? targetCategoryId = widget.categoryId;

    if (targetCategoryId == null) {
      try {
        targetCategoryId = await _getOrCreateUncategorizedCategory();
      } catch (error) {
        if (!mounted) return;
        _showSnackBar(
          AppErrorMessages.fromException(
            error,
            fallback: 'Could not prepare an uncategorized note.',
          ),
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
  }

  Future<String> _getOrCreateUncategorizedCategory() async {
    for (final category in _categories) {
      if (category.name.trim().toLowerCase() == 'uncategorized') {
        return category.id;
      }
    }

    await _categoryController.addCategory('Uncategorized');
    final categories = await _categoryController.getCategories();
    if (mounted) {
      setState(() => _categories = categories);
    }

    for (final category in categories) {
      if (category.name.trim().toLowerCase() == 'uncategorized') {
        return category.id;
      }
    }
    throw StateError('The Uncategorized category could not be found.');
  }

  Future<void> _openEditNote(_NoteEntry entry) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditNoteView(
          categoryId: entry.categoryId,
          noteId: entry.note.id,
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
  }

  Future<void> _deleteNote(_NoteEntry entry) async {
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
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not delete the note. Please try again.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingNoteIds.remove(entry.note.id));
      }
    }
  }

  Future<void> _confirmDeleteNote(_NoteEntry entry) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFD92D20).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD92D20),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete note?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This note will be permanently removed.',
                style: TextStyle(color: secondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side:
                            BorderSide(color: secondary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF17202A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD92D20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteNote(entry);
    }
  }

  void _goToCategories() {
    Navigator.of(context).pushNamedAndRemoveUntil('homepage', (route) => false);
  }

  @override
  void initState() {
    if (_useCache) {
      final cached =
          ScreenCache.read<(List<CategoryModel>, List<_NoteEntry>, String?)>(
              _cacheKey);
      if (cached != null) {
        _categories = cached.$1;
        _entries = cached.$2;
        _categoryTitle = cached.$3;
        _isLoading = false;
      }
    }
    _fetchNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);

    Widget notesList(List<_NoteEntry> entries, {bool isLast = false}) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, isLast ? 120 : 12),
        sliver: SliverList.separated(
          itemCount: entries.length,
          separatorBuilder: (context, i) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final entry = entries[i];
            return _NoteCard(
              entry: entry,
              isDark: isDark,
              muted: muted,
              showCategoryTag: _isAllNotesMode,
              isDeleting: _deletingNoteIds.contains(entry.note.id),
              onTap: () => _openEditNote(entry),
              onLongPress: () => _confirmDeleteNote(entry),
            );
          },
        ),
      );
    }

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
              foregroundColor: Colors.white,
              onPressed: _isLoading ? null : _openAddNote,
              child: const Icon(Icons.add_circle_outline, size: 28),
            ),
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: !_isAllNotesMode,
          titleSpacing: 20,
          title: Row(
            children: [
              if (_isAllNotesMode) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _kPrimaryOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sticky_note_2_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  _isAllNotesMode ? 'All Notes' : (_categoryTitle ?? 'Notes'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _isAllNotesMode
                    ? '${_entries.length} Total notes'
                    : '${_entries.length} Notes in category',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFFFF1D6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '${_entries.length} Notes',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: _kDeepOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: const [
            ThemeModeToggle(),
            SizedBox(width: 10),
          ],
        ),
        body: SafeArea(
          top: false,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
                  ? _NotesLoadError(
                      message: _loadError!,
                      onRetry: () => _fetchNotes(showLoading: true),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                          sliver: SliverToBoxAdapter(
                            child: _NotesSummaryBar(
                              isDark: isDark,
                              noteCount: _entries.length,
                              sortNewestFirst: _sortNewestFirst,
                              onToggleSort: () => setState(
                                () => _sortNewestFirst = !_sortNewestFirst,
                              ),
                            ),
                          ),
                        ),
                        if (_entries.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyNotes(isDark: isDark),
                          )
                        else if (_isAllNotesMode) ...[
                          SliverToBoxAdapter(
                            child: _NotesSectionHeader(
                              title: 'Uncategorized',
                              noteCount: _uncategorizedEntries.length,
                            ),
                          ),
                          if (_uncategorizedEntries.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 16),
                                child: Text(
                                  'Notes saved without a category will appear here.',
                                  style: TextStyle(color: muted),
                                ),
                              ),
                            )
                          else
                            notesList(
                              _uncategorizedEntries,
                              isLast: _categorizedEntries.isEmpty,
                            ),
                          if (_categorizedEntries.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: _NotesSectionHeader(
                                title: 'In categories',
                                noteCount: _categorizedEntries.length,
                              ),
                            ),
                            notesList(_categorizedEntries, isLast: true),
                          ],
                        ] else
                          notesList(_sortedEntries, isLast: true),
                      ],
                    ),
        ),
        bottomNavigationBar: _isAllNotesMode
            ? AppBottomNav(
                isDark: isDark,
                selectedTab: AppNavTab.notes,
                onTabSelected: (tab) {
                  switch (tab) {
                    case AppNavTab.notes:
                      break;
                    case AppNavTab.categories:
                      _goToCategories();
                      break;
                    case AppNavTab.settings:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsView(
                            authController: _authController,
                            onTabSelected: (settingsContext, selectedTab) {
                              switch (selectedTab) {
                                case AppNavTab.categories:
                                  Navigator.of(settingsContext)
                                      .pushNamedAndRemoveUntil(
                                    'homepage',
                                    (route) => false,
                                  );
                                  break;
                                case AppNavTab.notes:
                                  Navigator.of(settingsContext).pop();
                                  break;
                                case AppNavTab.settings:
                                  break;
                              }
                            },
                          ),
                        ),
                      );
                      break;
                  }
                },
              )
            : null,
      ),
    );
  }
}

class _NotesSummaryBar extends StatelessWidget {
  final bool isDark;
  final int noteCount;
  final bool sortNewestFirst;
  final VoidCallback onToggleSort;

  const _NotesSummaryBar({
    required this.isDark,
    required this.noteCount,
    required this.sortNewestFirst,
    required this.onToggleSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = isDark ? Colors.white70 : const Color(0xFF6B7280);
    return Row(
      children: [
        Icon(Icons.folder_open_outlined, size: 16, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$noteCount ${noteCount == 1 ? 'Note' : 'Notes'} • '
            '${sortNewestFirst ? 'Sorted by recent' : 'Sorted by oldest'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Tooltip(
          message: sortNewestFirst ? 'Show oldest first' : 'Show newest first',
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggleSort,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.swap_vert, size: 20, color: muted),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesSectionHeader extends StatelessWidget {
  final String title;
  final int noteCount;

  const _NotesSectionHeader({
    required this.title,
    required this.noteCount,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
        ? Colors.white60
        : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final _NoteEntry entry;
  final bool isDark;
  final Color muted;
  final bool isDeleting;
  final bool showCategoryTag;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NoteCard({
    required this.entry,
    required this.isDark,
    required this.muted,
    required this.isDeleting,
    required this.showCategoryTag,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = entry.note;
    final body = NoteContentCodec.plainText(note.note);
    final lines =
        body.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final title = note.title.trim().isNotEmpty
        ? note.title.trim()
        : (lines.isNotEmpty ? lines.first : body);
    final preview = lines.length > 1 ? lines.sublist(1).join(' ') : '';

    return Opacity(
      opacity: isDeleting ? 0.6 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242424) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : const Color(0xFFE5E7EB),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isDeleting ? null : onTap,
              onLongPress: isDeleting ? null : onLongPress,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showCategoryTag) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _kPrimaryOrange.withValues(
                                  alpha: isDark ? 0.24 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                entry.categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _kDeepOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (preview.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              preview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: muted,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 13, color: muted),
                              const SizedBox(width: 5),
                              Text(
                                _formatTimestamp(note.createdAt),
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isDeleting)
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      Icon(Icons.chevron_right_rounded, size: 20, color: muted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  final bool isDark;

  const _EmptyNotes({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_outlined, size: 56, color: muted),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "Add Note" to capture your first idea in this workspace.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NotesLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFD92D20)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTimestamp(DateTime? dateTime) {
  if (dateTime == null) return 'Just now';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[dateTime.month - 1];
  final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$month ${dateTime.day}, $hour12:$minute $period';
}
