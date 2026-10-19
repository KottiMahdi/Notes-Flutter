import 'package:flutter/material.dart';

import '../../../models/categorized_note_model.dart';
import 'note_card.dart';
import 'notes_empty_view.dart';
import 'notes_section_header.dart';
import 'notes_summary_bar.dart';

class NoteListScrollView extends StatelessWidget {
  final bool isDark;
  final bool isAllNotesMode;
  final List<CategorizedNoteModel> entries;
  final List<CategorizedNoteModel> uncategorizedEntries;
  final List<CategorizedNoteModel> categorizedEntries;
  final Set<String> deletingNoteIds;
  final bool sortNewestFirst;
  final VoidCallback onToggleSort;
  final ValueChanged<CategorizedNoteModel> onNoteTap;
  final ValueChanged<CategorizedNoteModel> onNoteLongPress;
  final VoidCallback? onAddNote;

  const NoteListScrollView({
    super.key,
    required this.isDark,
    required this.isAllNotesMode,
    required this.entries,
    required this.uncategorizedEntries,
    required this.categorizedEntries,
    required this.deletingNoteIds,
    required this.sortNewestFirst,
    required this.onToggleSort,
    required this.onNoteTap,
    required this.onNoteLongPress,
    this.onAddNote,
  });

  Widget _buildSliverList(
    List<CategorizedNoteModel> items, {
    required Color muted,
    bool isLast = false,
  }) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, isLast ? 120 : 12),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (context, i) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final entry = items[i];
          return NoteCard(
            entry: entry,
            isDark: isDark,
            muted: muted,
            showCategoryTag: isAllNotesMode,
            isDeleting: deletingNoteIds.contains(entry.note.id),
            onTap: () => onNoteTap(entry),
            onLongPress: () => onNoteLongPress(entry),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          sliver: SliverToBoxAdapter(
            child: NotesSummaryBar(
              isDark: isDark,
              noteCount: entries.length,
              sortNewestFirst: sortNewestFirst,
              onToggleSort: onToggleSort,
            ),
          ),
        ),
        if (entries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: NotesEmptyView(onAddNote: onAddNote),
          )
        else if (isAllNotesMode) ...[
          SliverToBoxAdapter(
            child: NotesSectionHeader(
              title: 'Uncategorized',
              noteCount: uncategorizedEntries.length,
            ),
          ),
          if (uncategorizedEntries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Text(
                  'Notes saved without a category will appear here.',
                  style: TextStyle(color: muted),
                ),
              ),
            )
          else
            _buildSliverList(
              uncategorizedEntries,
              muted: muted,
              isLast: categorizedEntries.isEmpty,
            ),
          if (categorizedEntries.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: NotesSectionHeader(
                title: 'In categories',
                noteCount: categorizedEntries.length,
              ),
            ),
            _buildSliverList(
              categorizedEntries,
              muted: muted,
              isLast: true,
            ),
          ],
        ] else
          _buildSliverList(entries, muted: muted, isLast: true),
      ],
    );
  }
}
