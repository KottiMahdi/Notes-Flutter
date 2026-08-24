import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_model.dart';
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
  List<CategoryModel> _categories = [];

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryController.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading categories: $e")),
      );
    }
  }

  Future<void> _signOut() async {
    await _authController.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await _categoryController.deleteCategory(id);
      _fetchCategories();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
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
          onPressed: () {
            Navigator.of(context).pushNamed("addCategory");
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Categorie"),
        ),
      ),
      appBar: AppBar(
        title: const Text('List of categories'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.exit_to_app),
          )
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
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          NoteListView(categoryId: category.id),
                    ));
                  },
                  onLongPress: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      title: 'Alert',
                      desc: 'Select Your Choice ',
                      btnOkText: "Edit",
                      btnOkOnPress: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UpdateCategoryView(
                            docId: category.id,
                            oldName: category.name,
                          ),
                        ));
                      },
                      btnCancelText: "Delete",
                      btnCancelOnPress: () => _deleteCategory(category.id),
                    ).show();
                  },
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/img/notes_752326.png",
                            height: 95,
                          ),
                          Text(category.name)
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
