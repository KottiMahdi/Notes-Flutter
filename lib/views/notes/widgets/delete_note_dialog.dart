import 'package:flutter/material.dart';
import '../../../core/widgets/scrollable_dialog_content.dart';

class DeleteNoteDialog extends StatelessWidget {
  final bool isDark;

  const DeleteNoteDialog({
    super.key,
    required this.isDark,
  });

  static Future<bool?> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => DeleteNoteDialog(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ScrollableDialogContent(
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
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: secondary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF17202A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
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
    );
  }
}
