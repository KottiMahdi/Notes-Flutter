import 'package:flutter/material.dart';

import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/note_content_codec.dart';
import '../../../models/categorized_note_model.dart';

class NoteCard extends StatefulWidget {
  final CategorizedNoteModel entry;
  final bool isDark;
  final Color muted;
  final bool isDeleting;
  final bool showCategoryTag;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static const primaryOrange = Color(0xFFF59E0B);

  const NoteCard({
    super.key,
    required this.entry,
    required this.isDark,
    required this.muted,
    required this.isDeleting,
    required this.showCategoryTag,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late _NotePreview _preview;

  @override
  void initState() {
    super.initState();
    _preview = _createPreview(widget.entry);
  }

  @override
  void didUpdateWidget(NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.note.note != widget.entry.note.note ||
        oldWidget.entry.note.title != widget.entry.note.title) {
      _preview = _createPreview(widget.entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;
    final note = entry.note;
    final title = _preview.title;
    final preview = _preview.preview;
    final isDark = widget.isDark;
    final muted = widget.muted;
    final isDeleting = widget.isDeleting;
    final showCategoryTag = widget.showCategoryTag;
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;

    return Opacity(
      opacity: isDeleting ? 0.6 : 1,
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
                            color: NoteCard.primaryOrange.withValues(
                              alpha: isDark ? 0.24 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entry.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
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
                            DateFormatUtils.formatTimestamp(note.createdAt),
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
    );
  }
}

class _NotePreview {
  final String title;
  final String preview;

  const _NotePreview({required this.title, required this.preview});
}

_NotePreview _createPreview(CategorizedNoteModel entry) {
  final body = NoteContentCodec.plainText(entry.note.note);
  final lines =
      body.split('\n').where((line) => line.trim().isNotEmpty).toList();
  final noteTitle = entry.note.title.trim();
  final title = noteTitle.isNotEmpty
      ? noteTitle
      : (lines.isNotEmpty ? lines.first : body);
  final preview = lines.length > 1 ? lines.sublist(1).join(' ') : '';

  return _NotePreview(title: title, preview: preview);
}
