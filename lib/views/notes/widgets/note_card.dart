import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/note_content_codec.dart';
import '../../../models/categorized_note_model.dart';

class NoteCard extends StatelessWidget {
  final CategorizedNoteModel entry;
  final bool isDark;
  final Color muted;
  final bool isDeleting;
  final bool showCategoryTag;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static const primaryOrange = Color(0xFFF59E0B);
  static const deepOrange = Color(0xFFC66A00);

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
                                color: primaryOrange.withValues(
                                  alpha: isDark ? 0.24 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                entry.categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: deepOrange,
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
        ),
      ),
    );
  }
}
