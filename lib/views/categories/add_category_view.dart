import 'package:flutter/material.dart';
import '../../controllers/category_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AddCategoryView extends StatefulWidget {
  const AddCategoryView({super.key});

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final CategoryController _categoryController = CategoryController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);
      await _categoryController.addCategory(_nameCtrl.text);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('homepage', (route) => false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Add failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Category"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 25),
                    child: CustomTextField(
                      hintText: "Enter Name",
                      mycontroller: _nameCtrl,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Can't be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  CustomButton(
                    title: "Add",
                    onPressed: _addCategory,
                  )
                ],
              ),
            ),
    );
  }
}
