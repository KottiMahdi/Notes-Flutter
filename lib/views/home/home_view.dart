import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_model.dart';
import '../../core/utils/app_error_messages.dart';
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadCategories({bool showLoading = false}) async {
    try {
      await _viewModel.loadCategories(showLoading: showLoading);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not load categories. Please try again.',
        ),
      );
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

  Future<void> _openAddCategory() async {
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
  }

  Future<void> _openEditCategory(CategoryModel category) async {
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
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    try {
      await _viewModel.deleteCategory(category);
      if (!mounted) return;
      await showSuccessDialog(
        context: context,
        title: 'Category deleted',
        message: '"${category.name}" and its notes have been removed.',
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not delete the category. Please try again.',
        ),
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
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final viewModel = _viewModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);
    final isNarrow = MediaQuery.sizeOf(context).width < 400;
    final visibleCategories = viewModel.visibleCategories;
    final selectedFilter = categoryFilterLabels[viewModel.selectedFilterIndex];
    final sectionTitle = viewModel.selectedFilterIndex == 0
        ? 'ALL WORKSPACES'
        : '${selectedFilter.toUpperCase()} CATEGORIES';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFFFFCF7),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: SizedBox(
          height: 54,
          child: FloatingActionButton(
            tooltip: 'Add category',
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            onPressed: viewModel.isLoading ? null : _openAddCategory,
            child: const Icon(Icons.add_circle_outline, size: 28),
          ),
        ),
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
                color: Colors.white,
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
            Tooltip(
              message: '${viewModel.categories.length} Active categories',
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
                  '${viewModel.categories.length} Active',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? const Color(0xFFFFB74D)
                        : const Color(0xFFC66A00),
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategoryFilters(
                            isDark: isDark,
                            selectedIndex: viewModel.selectedFilterIndex,
                            onChanged: viewModel.selectFilter,
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Text(
                                sectionTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF8EA1BC),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
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
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyCategories(),
                    )
                  else if (visibleCategories.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyCategories(
                        title: 'No $selectedFilter categories',
                        message:
                            'Try another filter or add a ${selectedFilter.toLowerCase()} category.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final category = visibleCategories[i];
                            return CategoryCard(
                              key: ValueKey(category.id),
                              category: category,
                              noteCount: viewModel.noteCounts[category.id] ?? 0,
                              isDeleting: viewModel.deletingCategoryIds
                                  .contains(category.id),
                              muted: muted,
                              onOpen: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NoteListView(categoryId: category.id),
                                ),
                              ),
                              onManage: () =>
                                  _showManageCategorySheet(category),
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
