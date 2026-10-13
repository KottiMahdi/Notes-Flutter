import 'package:flutter/material.dart';

import '../../../controllers/auth_controller.dart';
import '../../settings/settings_view.dart';
import '../../widgets/app_bottom_nav.dart';

class NoteListBottomNav extends StatelessWidget {
  final bool isDark;
  final AuthController authController;
  final VoidCallback onGoToCategories;

  const NoteListBottomNav({
    super.key,
    required this.isDark,
    required this.authController,
    required this.onGoToCategories,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      isDark: isDark,
      selectedTab: AppNavTab.notes,
      onTabSelected: (tab) {
        switch (tab) {
          case AppNavTab.notes:
            break;
          case AppNavTab.categories:
            onGoToCategories();
            break;
          case AppNavTab.settings:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsView(
                  authController: authController,
                  onTabSelected: (settingsContext, selectedTab) {
                    switch (selectedTab) {
                      case AppNavTab.categories:
                        Navigator.of(settingsContext).pushNamedAndRemoveUntil(
                          'homepage',
                          (route) => false,
                        );
                        break;
                      case AppNavTab.notes:
                        Navigator.of(settingsContext).pop();
                        break;
                      case AppNavTab.settings:
                        break;
                    }
                  },
                ),
              ),
            );
            break;
        }
      },
    );
  }
}
