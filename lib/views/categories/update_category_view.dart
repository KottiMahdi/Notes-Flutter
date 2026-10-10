import 'package:flutter/material.dart';

import '../../controllers/category_controller.dart';
import '../../utils/app_error_messages.dart';
import '../../utils/theme_mode_scope.dart';
import 'add_category_view.dart';

class UpdateCategoryView extends StatefulWidget {
  final String docId;
  final String oldName;
  final int oldIconCode;
  final int oldAccentColor;
  final String oldType;
  final CategoryController? categoryController;

  const UpdateCategoryView({
    super.key,
    required this.docId,
    required this.oldName,
    this.oldIconCode = 0xe2c8,
    this.oldAccentColor = 0xFFF59E0B,
    this.oldType = 'Personal',
    this.categoryController,
  });

  @override
  State<UpdateCategoryView> createState() => _UpdateCategoryViewState();
}

class _UpdateCategoryViewState extends State<UpdateCategoryView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  late final CategoryController _categoryController =
      widget.categoryController ?? CategoryController();
  bool _isLoading = false;
  late IconData _selectedIcon =
      IconData(widget.oldIconCode, fontFamily: 'MaterialIcons');
  late Color _selectedAccent = Color(widget.oldAccentColor);
  late String _selectedType = _types.first;

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
  void initState() {
    super.initState();
    _nameCtrl.text = widget.oldName;
    _nameCtrl.addListener(_refreshPreview);
    _selectedType =
        _types.contains(widget.oldType) ? widget.oldType : _types.last;
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_refreshPreview);
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _categoryController.updateCategory(
        widget.docId,
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
              fallback: 'Could not update the category. Please try again.',
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
        title: const Text('Edit Category'),
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
                          onPressed: _updateCategory,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
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
