import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/category_controller.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/widgets/retry_snack_bar.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/theme_mode_scope.dart';
import 'widgets/category_selection_controls.dart';

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
  late String _selectedType = categoryTypes.first;

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.oldName;
    _nameCtrl.addListener(_refreshPreview);
    _selectedType = categoryTypes.contains(widget.oldType)
        ? widget.oldType
        : categoryTypes.last;
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
      showRetrySnackBar(
        context,
        message: AppErrorMessages.fromException(
          error,
          fallback: 'Could not update the category. Please try again.',
        ),
        onRetry: _updateCategory,
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
            ? const LoadingView(message: 'Saving category')
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryPreviewCard(
                        isDark: isDark,
                        categoryName: categoryName,
                        icon: _selectedIcon,
                        accentColor: _selectedAccent,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Category Name',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                        ],
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                      CategoryTypeSelector(
                        isDark: isDark,
                        types: categoryTypes,
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
                            for (final symbol in categorySymbols)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CategorySymbolChoice(
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
                            for (final accent in categoryAccents)
                              CategoryAccentChoice(
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
                          onPressed: _isLoading ? null : _updateCategory,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: const Color(0xFF17202A),
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
