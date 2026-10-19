import 'dart:ui';

import 'package:flutter/material.dart';

enum AppNavTab { notes, categories, settings }

/// Frosted bottom navigation bar shared across the categories and notes
/// screens to keep the tab bar visually consistent across the app.
class AppBottomNav extends StatelessWidget {
  final bool isDark;
  final AppNavTab selectedTab;
  final ValueChanged<AppNavTab> onTabSelected;

  const AppBottomNav({
    super.key,
    required this.isDark,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = colors.primary;
    final inactive = colors.onSurfaceVariant;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF242424).withValues(alpha: 0.9)
                    : const Color(0xFFFFFEFA),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE8DED0),
                ),
                boxShadow: isDark
                    ? const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.folder_outlined,
                      label: 'Categories',
                      selected: selectedTab == AppNavTab.categories,
                      selectedColor: selected,
                      inactiveColor: inactive,
                      onTap: () => onTabSelected(AppNavTab.categories),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.notes_outlined,
                      label: 'Notes',
                      selected: selectedTab == AppNavTab.notes,
                      selectedColor: selected,
                      inactiveColor: inactive,
                      onTap: () => onTabSelected(AppNavTab.notes),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      selected: selectedTab == AppNavTab.settings,
                      selectedColor: selected,
                      inactiveColor: inactive,
                      onTap: () => onTabSelected(AppNavTab.settings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selectedColor,
    required this.inactiveColor,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : inactiveColor;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox.expand(
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
