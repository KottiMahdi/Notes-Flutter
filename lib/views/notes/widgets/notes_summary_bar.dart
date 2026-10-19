import 'package:flutter/material.dart';

class NotesSummaryBar extends StatelessWidget {
  final bool isDark;
  final int noteCount;
  final bool sortNewestFirst;
  final VoidCallback onToggleSort;

  const NotesSummaryBar({
    super.key,
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
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(Icons.swap_vert, size: 20, color: muted),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
