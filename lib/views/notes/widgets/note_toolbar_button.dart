import 'package:flutter/material.dart';

class NoteToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  const NoteToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor =
        isDark ? const Color(0xFFFFB74D) : const Color(0xFFC66A00);
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isActive
              ? activeColor.withValues(alpha: isDark ? 0.24 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                icon,
                size: 18,
                color: isActive
                    ? activeColor
                    : (onTap == null ? theme.disabledColor : null),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
