import 'package:flutter/material.dart';

class ThemeModeScope extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  static final ValueNotifier<ThemeMode> fallbackNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  const ThemeModeScope({
    super.key,
    required ValueNotifier<ThemeMode> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
    return scope?.notifier ?? fallbackNotifier;
  }
}

class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = ThemeModeScope.of(context);
    final isDark = mode.value == ThemeMode.dark;
    return IconButton(
      tooltip: isDark ? 'Use light mode' : 'Use dark mode',
      onPressed: () => mode.value = isDark ? ThemeMode.light : ThemeMode.dark,
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}
