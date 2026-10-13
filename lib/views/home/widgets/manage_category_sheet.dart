import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import 'manage_category_action.dart';

/// Shows the "Edit / Delete" bottom sheet for a long-pressed category card.
Future<void> showManageCategorySheet({
  required BuildContext context,
  required CategoryModel category,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);
  final accent = Color(category.accentColor);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.28 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.25)),
                  ),
                  child: Icon(
                    IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ManageCategoryAction(
              icon: Icons.edit_outlined,
              label: 'Edit category',
              color: accent,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onEdit();
              },
            ),
            const SizedBox(height: 10),
            ManageCategoryAction(
              icon: Icons.delete_outline,
              label: 'Delete category',
              color: const Color(0xFFD92D20),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
