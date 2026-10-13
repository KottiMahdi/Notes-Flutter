import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

/// Grid tile representing a single category, with tap-to-open and
/// long-press-to-manage (edit/delete) interactions.
class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int noteCount;
  final bool isDeleting;
  final Color muted;
  final VoidCallback onOpen;
  final VoidCallback onManage;

  const CategoryCard({
    super.key,
    required this.category,
    required this.noteCount,
    required this.isDeleting,
    required this.muted,
    required this.onOpen,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = Color(category.accentColor);

    return Opacity(
      opacity: isDeleting ? 0.6 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242424) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : accent.withValues(alpha: 0.16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: isDeleting ? null : onOpen,
              onLongPress: isDeleting ? null : onManage,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: isDark ? 0.28 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            IconData(
                              category.iconCode,
                              fontFamily: 'MaterialIcons',
                            ),
                            color: accent,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFF0F1F3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: muted.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 14, color: muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              noteCount == 0 ? 'Empty' : 'Updated recently',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: muted),
                        ],
                      ),
                    ),
                    if (isDeleting)
                      const Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
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
