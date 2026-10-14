import 'package:flutter/foundation.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/category_model.dart';
import '../../../core/utils/screen_cache.dart';
import 'category_filter_options.dart';

class HomeViewModel extends ChangeNotifier {
  final CategoryController categoryController;
  final bool useCache;

  HomeViewModel({
    required this.categoryController,
    this.useCache = true,
  });

  bool _disposed = false;
  bool isLoading = true;
  int selectedFilterIndex = 0;
  List<CategoryModel> categories = [];
  Map<String, int> noteCounts = {};
  final Set<String> deletingCategoryIds = {};

  List<CategoryModel> get visibleCategories {
    final selectedFilter = categoryFilterLabels[selectedFilterIndex];
    if (selectedFilter == 'All') return categories;

    return categories
        .where(
          (category) =>
              category.type.trim().toLowerCase() ==
              selectedFilter.toLowerCase(),
        )
        .toList();
  }

  void initialize() {
    if (useCache) {
      final cached =
          ScreenCache.read<(List<CategoryModel>, Map<String, int>)>('home');
      if (cached != null) {
        categories = cached.$1;
        noteCounts = cached.$2;
        isLoading = false;
      }
    }
  }

  Future<void> loadCategories({bool showLoading = false}) async {
    if (showLoading) {
      isLoading = true;
    }
    _notify();

    try {
      final loadedCategories = await categoryController.getCategories();
      final counts = await Future.wait<int>(
        loadedCategories.map(
          (category) => categoryController.getNoteCount(category.id),
        ),
      );
      final loadedNoteCounts = <String, int>{
        for (var index = 0; index < loadedCategories.length; index++)
          loadedCategories[index].id: counts[index],
      };

      categories = loadedCategories;
      noteCounts = loadedNoteCounts;
      isLoading = false;
      if (useCache) {
        ScreenCache.write('home', (loadedCategories, loadedNoteCounts));
      }
      _notify();
    } catch (_) {
      isLoading = false;
      _notify();
      rethrow;
    }
  }

  void selectFilter(int index) {
    selectedFilterIndex = index;
    _notify();
  }

  Future<void> deleteCategory(CategoryModel category) async {
    final id = category.id;
    if (!deletingCategoryIds.add(id)) return;
    _notify();

    try {
      await categoryController.deleteCategory(id);
      await loadCategories();
    } finally {
      deletingCategoryIds.remove(id);
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
