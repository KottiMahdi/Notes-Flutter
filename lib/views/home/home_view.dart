import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_model.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/widgets/retry_snack_bar.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/theme_mode_scope.dart';
import '../categories/update_category_view.dart';
import '../notes/note_list_view.dart';
import '../settings/settings_view.dart';
import '../widgets/app_bottom_nav.dart';
import 'widgets/category_card.dart';
import 'widgets/category_filters.dart';
import 'widgets/delete_category_dialog.dart';
import 'widgets/empty_categories.dart';
import 'widgets/manage_category_sheet.dart';
import 'widgets/success_dialog.dart';
import 'category_filter_options.dart';
import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  final CategoryController? categoryController;
  final AuthController? authController;

  const HomeView({
    super.key,
    this.categoryController,
    this.authController,
  });
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final CategoryController _categoryController =
      widget.categoryController ?? CategoryController();
  late final AuthController _authController =
      widget.authController ?? AuthController();
  late final HomeViewModel _viewModel = HomeViewModel(
    categoryController: _categoryController,
    useCache: widget.categoryController == null,
  );
  String? _loadError;
  bool _isOpeningAddCategory = false;
  final Set<String> _openingCategoryIds = {};

  Future<void> _loadCategories({bool showLoading = false}) async {
    if (mounted) {
      setState(() => _loadError = null);
    }
    try {
      await _viewModel.loadCategories(showLoading: showLoading);
    } catch (error) {
      if (!mounted) return;
      final message = AppErrorMessages.fromException(
        error,
        fallback: 'Could not load categories. Please try again.',
      );
      if (_viewModel.categories.isEmpty) {
        setState(() => _loadError = message);
      } else {
        showRetrySnackBar(
          context,
          message: message,
          onRetry: () => _loadCategories(showLoading: false),
        );
      }
    }
  }

  Future<void> _openNotesTab() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteListView(),
      ),
    );
    if (!mounted) return;
    await _loadCategories();
  }

  Future<void> _openCategoryNotes(CategoryModel category) async {
    if (!_openingCategoryIds.add(category.id)) return;
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteListView(
            categoryId: category.id,
            categoryName: category.name,
          ),
        ),
      );
      if (!mounted) return;
      await _loadCategories();
    } finally {
      _openingCategoryIds.remove(category.id);
    }
  }

  Future<void> _openAddCategory() async {
    if (_isOpeningAddCategory) return;
    setState(() => _isOpeningAddCategory = true);
    try {
      final changed = await Navigator.of(context).pushNamed('addCategory');
      if (!mounted) return;
      if (changed == true) {
        await showSuccessDialog(
          context: context,
          title: 'Category added',
          message: 'Your new category is ready to hold notes.',
        );
        if (!mounted) return;
        await _loadCategories();
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningAddCategory = false);
      }
    }
  }

  Future<void> _openEditCategory(CategoryModel category) async {
    if (!_openingCategoryIds.add(category.id)) return;
    try {
      final changed = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdateCategoryView(
            docId: category.id,
            oldName: category.name,
            oldIconCode: category.iconCode,
            oldAccentColor: category.accentColor,
            oldType: category.type,
          ),
        ),
      );
      if (!mounted) return;
      if (changed == true) {
        await showSuccessDialog(
          context: context,
          title: 'Category updated',
          message: 'Your changes have been saved.',
        );
        if (!mounted) return;
        await _loadCategories();
      }
    } finally {
      _openingCategoryIds.remove(category.id);
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    try {
      final deleted = await _viewModel.deleteCategory(category);
      if (!deleted) return;
      if (!mounted) return;
      await showSuccessDialog(
        context: context,
        title: 'Category deleted',
        message: '"${category.name}" and its notes have been removed.',
      );
    } catch (error) {
      if (!mounted) return;
      showRetrySnackBar(
        context,
        message: AppErrorMessages.fromException(
          error,
          fallback: 'Could not delete the category. Please try again.',
        ),
        onRetry: () => _deleteCategory(category),
      );
    }
  }

  Future<void> _confirmDeleteCategory(CategoryModel category) async {
    final confirmed = await showDeleteCategoryDialog(
      context: context,
      category: category,
    );
    if (confirmed == true) {
      await _deleteCategory(category);
    }
  }

  Future<void> _showManageCategorySheet(CategoryModel category) {
    return showManageCategorySheet(
      context: context,
      category: category,
      onEdit: () => _openEditCategory(category),
      onDelete: () => _confirmDeleteCategory(category),
    );
  }

  @override
  void initState() {
    super.initState();
    _viewModel.initialize();
    _loadCategories();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 400;
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFFFFCF7),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: SizedBox(
              height: 54,
              child: FloatingActionButton(
                tooltip: 'Add category',
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF17202A),
                onPressed: _viewModel.isLoading || _isOpeningAddCategory
                    ? null
                    : _openAddCategory,
                child: _isOpeningAddCategory
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF17202A),
                        ),
                      )
                    : const Icon(Icons.add_circle_outline, size: 28),
              ),
            ),
          );
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleSpacing: isNarrow ? 12 : 20,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sticky_note_2_outlined,
                color: Color(0xFF17202A),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'All Categories',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: isNarrow ? 19 : 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  final categoryCount = _viewModel.categories.length;
                  return Tooltip(
                    message: '$categoryCount Active categories',
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 9 : 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFFC66A00).withValues(alpha: 0.24)
                            : const Color(0xFFFFF1D6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '$categoryCount Active',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isDark
                              ? const Color(0xFFFFB74D)
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: const [
          ThemeModeToggle(),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            final viewModel = _viewModel;
            final visibleCategories = viewModel.visibleCategories;
            final selectedFilter =
                categoryFilterLabels[viewModel.selectedFilterIndex];
            final sectionTitle = viewModel.selectedFilterIndex == 0
                ? 'ALL WORKSPACES'
                : '${selectedFilter.toUpperCase()} CATEGORIES';

            return viewModel.isLoading
                ? const LoadingView(message: 'Loading categories')
                : _loadError != null && viewModel.categories.isEmpty
                    ? ErrorView(
                        message: _loadError!,
                        onRetry: () => _loadCategories(showLoading: true),
                      )
                    : Column(
                        children: [
                          if (viewModel.isRefreshing)
                            const LinearProgressIndicator(
                              minHeight: 2,
                              semanticsLabel: 'Refreshing categories',
                            ),
                          Expanded(
                            child: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 20, 10),
                                  sliver: SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CategoryFilters(
                                          isDark: isDark,
                                          selectedIndex:
                                              viewModel.selectedFilterIndex,
                                          onChanged: viewModel.selectFilter,
                                        ),
                                        const SizedBox(height: 30),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                sectionTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  color: isDark
                                                      ? Colors.white70
                                                      : theme.colorScheme
                                                          .onSurfaceVariant,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                      ],
                                    ),
                                  ),
                                ),
                                if (viewModel.categories.isEmpty)
                                  SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: EmptyCategories(
                                        onAddCategory: _openAddCategory),
                                  )
                                else if (visibleCategories.isEmpty)
                                  SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: EmptyCategories(
                                      title: 'No $selectedFilter categories',
                                      message:
                                          'Try another filter or add a ${selectedFilter.toLowerCase()} category.',
                                      onAddCategory: _openAddCategory,
                                    ),
                                  )
                                else
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 120),
                                    sliver: SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, i) {
                                          final category = visibleCategories[i];
                                          return CategoryCard(
                                            key: ValueKey(category.id),
                                            category: category,
                                            noteCount: viewModel
                                                    .noteCounts[category.id] ??
                                                0,
                                            isDeleting: viewModel
                                                .deletingCategoryIds
                                                .contains(category.id),
                                            muted: muted,
                                            onOpen: () =>
                                                _openCategoryNotes(category),
                                            onManage: () =>
                                                _showManageCategorySheet(
                                                    category),
                                          );
                                        },
                                        childCount: visibleCategories.length,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 260,
                                        childAspectRatio: 0.86,
                                        crossAxisSpacing: 30,
                                        mainAxisSpacing: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        isDark: isDark,
        selectedTab: AppNavTab.categories,
        onTabSelected: (tab) {
          switch (tab) {
            case AppNavTab.categories:
              break;
            case AppNavTab.notes:
              _openNotesTab();
              break;
            case AppNavTab.settings:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsView(
                    authController: _authController,
                    onTabSelected: (settingsContext, selectedTab) {
                      switch (selectedTab) {
                        case AppNavTab.categories:
                          Navigator.of(settingsContext).pushNamedAndRemoveUntil(
                            'homepage',
                            (route) => false,
                          );
                          break;
                        case AppNavTab.notes:
                          Navigator.of(settingsContext).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const NoteListView(),
                            ),
                          );
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
      ),
    );
  }
}
