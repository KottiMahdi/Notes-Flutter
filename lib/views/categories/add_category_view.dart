import 'package:flutter/material.dart';

import '../../controllers/category_controller.dart';
import '../../utils/app_error_messages.dart';
import '../../utils/theme_mode_scope.dart';

class AddCategoryView extends StatefulWidget {
  final CategoryController? categoryController;

  const AddCategoryView({
    super.key,
    this.categoryController,
  });

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  late final CategoryController _categoryController =
      widget.categoryController ?? CategoryController();
  bool _isLoading = false;
  IconData _selectedIcon = Icons.folder_open;
  Color _selectedAccent = const Color(0xFFF59E0B);
  String _selectedType = _types.first;

  static const _types = ['Work', 'Academic', 'Personal'];

  static const _symbols = [
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

  static const _accents = [
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

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_refreshPreview);
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_refreshPreview);
  }

  Future<void> _addCategory() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _categoryController.addCategory(
        _nameCtrl.text,
        iconCode: _selectedIcon.codePoint,
        accentColor: _selectedAccent.toARGB32(),
        type: _selectedType,
      );
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('homepage', (route) => false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorMessages.fromException(
              error,
              fallback: 'Could not add the category. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF121212) : const Color(0xFFFFFCF7);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);
    final categoryName = _nameCtrl.text.trim();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: const Text('Add Category'),
        actions: const [
          ThemeModeToggle(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: secondary.withValues(alpha: 0.16),
                          ),
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
                                    color: _selectedAccent.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _selectedIcon,
                                    color: _selectedAccent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    categoryName.isEmpty
                                        ? 'Category Name'
                                        : categoryName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF17202A),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFF2E8B57),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Text(
                            'Category Name',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(color: Color(0xFFD92D20)),
                          ),
                          const Spacer(),
                          Text(
                            '${_nameCtrl.text.length}/30',
                            style: TextStyle(color: secondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Enter name',
                          prefixIcon: const Icon(Icons.folder_open),
                          filled: true,
                          fillColor: surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: secondary.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFF59E0B),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Can't be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Category Type',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TypeSegmented(
                        isDark: isDark,
                        types: _types,
                        selected: _selectedType,
                        onChanged: (type) =>
                            setState(() => _selectedType = type),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Choose Symbol',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final symbol in _symbols)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SymbolChoice(
                                  icon: symbol,
                                  selected: _selectedIcon == symbol,
                                  onTap: () => setState(() {
                                    _selectedIcon = symbol;
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Accent Palette',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final accent in _accents)
                              ColorChoice(
                                color: accent,
                                selected: _selectedAccent == accent,
                                onTap: () => setState(() {
                                  _selectedAccent = accent;
                                }),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _addCategory,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: secondary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Organizing Tip\nCategories help you group notes together. You can always rename or delete them later.',
                                style: TextStyle(
                                  color: secondary,
                                  height: 1.45,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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

class TypeSegmented extends StatelessWidget {
  final bool isDark;
  final List<String> types;
  final String selected;
  final ValueChanged<String> onChanged;

  const TypeSegmented({
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

class SymbolChoice extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const SymbolChoice({
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

class ColorChoice extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const ColorChoice({
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
                    color: Theme.of(context).colorScheme.onSurface, width: 3)
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
