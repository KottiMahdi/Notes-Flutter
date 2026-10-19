import 'package:flutter/material.dart';
import '../../../core/widgets/scrollable_dialog_content.dart';

/// Shows a success confirmation dialog matching the app's design system
/// (e.g. after adding or updating a category).
Future<void> showSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
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
                color: const Color(0xFF2E8B57).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF2E8B57),
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: secondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: const Color(0xFF17202A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
