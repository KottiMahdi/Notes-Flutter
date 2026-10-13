import 'package:flutter/material.dart';

const categoryTypes = ['Work', 'Academic', 'Personal'];

const categorySymbols = [
  Icons.folder_open,
  Icons.menu_book_outlined,
  Icons.school_outlined,
  Icons.sell_outlined,
  Icons.bookmark_outline,
  Icons.auto_awesome,
  Icons.work_outline,
  Icons.home_outlined,
  Icons.favorite_outline,
  Icons.lightbulb_outline,
];

const categoryAccents = [
  Color(0xFFF59E0B),
  Color(0xFF2E8B57),
  Color(0xFF4F7CAC),
  Color(0xFF9B6A9E),
  Color(0xFFE07A5F),
  Color(0xFFE85D9E),
  Color(0xFF3B82F6),
  Color(0xFF14B8A6),
  Color(0xFF8B5CF6),
  Color(0xFFEF4444),
  Color(0xFF64748B),
];

class CategoryPreviewCard extends StatelessWidget {
  final bool isDark;
  final String categoryName;
  final IconData icon;
  final Color accentColor;
  final bool showNoteCount;

  const CategoryPreviewCard({
    super.key,
    required this.isDark,
    required this.categoryName,
    required this.icon,
    required this.accentColor,
    this.showNoteCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: secondary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Category Preview',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showNoteCount)
                const Text(
                  '  •  0 notes',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  categoryName.isEmpty ? 'Category Name' : categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF17202A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.verified, color: Color(0xFF2E8B57)),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryTypeSelector extends StatelessWidget {
  final bool isDark;
  final List<String> types;
  final String selected;
  final ValueChanged<String> onChanged;

  const CategoryTypeSelector({
    super.key,
    required this.isDark,
    required this.types,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFEFF1F3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          for (final type in types)
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: type == selected
                    ? BoxDecoration(
                        color: isDark ? const Color(0xFF303030) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      )
                    : null,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onChanged(type),
                  child: Center(
                    child: Text(
                      type,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: type == selected
                                ? (isDark
                                    ? Colors.white
                                    : const Color(0xFF17202A))
                                : (isDark
                                    ? Colors.white60
                                    : const Color(0xFF60738E)),
                            fontWeight: type == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CategorySymbolChoice extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CategorySymbolChoice({
    super.key,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Choose category symbol',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFE7B0) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF59E0B)
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected
                ? const Color(0xFFC66A00)
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class CategoryAccentChoice extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const CategoryAccentChoice({
    super.key,
    required this.color,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Choose category accent color',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 3,
                  )
                : null,
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 17)
              : null,
        ),
      ),
    );
  }
}
