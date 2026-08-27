import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_error_messages.dart';
import '../categories/update_category_view.dart';
import '../notes/note_list_view.dart';

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

  bool _isLoading = true;
  bool _isSigningOut = false;
  final Set<String> _deletingCategoryIds = {};
  List<CategoryModel> _categories = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _fetchCategories({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final categories = await _categoryController.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not load categories. Please try again.',
        ),
      );
    }
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() => _isSigningOut = true);
    try {
      await _authController.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not sign out. Please try again.',
        ),
      );
    }
  }

  Future<void> _openAddCategory() async {
    final changed = await Navigator.of(context).pushNamed('addCategory');
    if (!mounted) return;
    if (changed == true) {
      _showSnackBar('Category added.');
      await _fetchCategories();
    }
  }

  Future<void> _openEditCategory(CategoryModel category) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpdateCategoryView(
          docId: category.id,
          oldName: category.name,
        ),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      _showSnackBar('Category updated.');
      await _fetchCategories();
    }
  }

  Future<void> _deleteCategory(String id) async {
    if (_deletingCategoryIds.contains(id)) return;

    setState(() => _deletingCategoryIds.add(id));
    try {
      await _categoryController.deleteCategory(id);
      if (!mounted) return;
      _showSnackBar('Category deleted.');
      await _fetchCategories();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not delete the category. Please try again.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingCategoryIds.remove(id));
      }
    }
  }

  @override
  void initState() {
    _fetchCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          onPressed: _isLoading || _isSigningOut ? null : _openAddCategory,
          icon: const Icon(Icons.add),
          label: const Text('Add Categorie'),
        ),
      ),
      appBar: AppBar(
        title: const Text('List of categories'),
        actions: [
          IconButton(
            onPressed: _isSigningOut ? null : _signOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 160,
              ),
              itemBuilder: (context, i) {
                final category = _categories[i];
                final isDeleting = _deletingCategoryIds.contains(category.id);
                return InkWell(
                  onTap: isDeleting
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoteListView(categoryId: category.id),
                            ),
                          );
                        },
                  onLongPress: isDeleting
                      ? null
                      : () {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title: 'Alert',
                            desc: 'Select Your Choice ',
                            btnOkText: 'Edit',
                            btnOkOnPress: () => _openEditCategory(category),
                            btnCancelText: 'Delete',
                            btnCancelOnPress: () =>
                                _deleteCategory(category.id),
                          ).show();
                        },
                  child: Opacity(
                    opacity: isDeleting ? 0.6 : 1,
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isDeleting)
                              const SizedBox(
                                height: 95,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else
                              Image.asset(
                                'assets/img/notes_752326.png',
                                height: 95,
                              ),
                            Text(category.name),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
