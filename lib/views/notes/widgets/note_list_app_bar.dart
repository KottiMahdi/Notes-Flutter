import 'package:flutter/material.dart';

import '../../../core/widgets/theme_mode_scope.dart';

const _kPrimaryOrange = Color(0xFFF59E0B);

class NoteListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAllNotesMode;
  final String title;
  final int noteCount;

  const NoteListAppBar({
    super.key,
    required this.isAllNotesMode,
    required this.title,
    required this.noteCount,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: !isAllNotesMode,
      titleSpacing: 20,
      title: Row(
        children: [
          if (isAllNotesMode) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _kPrimaryOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sticky_note_2_outlined,
                color: Color(0xFF17202A),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Tooltip(
              message: isAllNotesMode
                  ? '$noteCount Total notes'
                  : '$noteCount Notes in category',
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
                  '$noteCount Notes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
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
    );
  }
}
