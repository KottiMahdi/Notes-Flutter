import 'package:flutter/material.dart';
import '../category_filter_options.dart';

/// Segmented filter row shown above the categories grid.
class CategoryFilters extends StatelessWidget {
  final bool isDark;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CategoryFilters({
    super.key,
    required this.isDark,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      height: 64,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFEFF1F3),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          for (var index = 0; index < categoryFilterLabels.length; index++)
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: index == selectedIndex
                    ? BoxDecoration(
                        color: isDark ? const Color(0xFF303030) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      )
                    : null,
                child: Semantics(
                  button: true,
                  selected: index == selectedIndex,
                  inMutuallyExclusiveGroup: true,
                  label: categoryFilterLabels[index],
                  child: SizedBox.expand(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => onChanged(index),
                      child: Center(
                        child: Text(
                          categoryFilterLabels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: index == selectedIndex
                                    ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF17202A))
                                    : (isDark ? Colors.white60 : inactiveColor),
                                fontWeight: index == selectedIndex
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                        ),
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
