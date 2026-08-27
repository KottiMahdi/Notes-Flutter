import 'package:flutter/material.dart';

import '../../controllers/category_controller.dart';
import '../../utils/app_error_messages.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

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

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _categoryController.addCategory(_nameCtrl.text);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 25,
                    ),
                    child: CustomTextField(
                      hintText: 'Enter Name',
                      mycontroller: _nameCtrl,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Can't be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  CustomButton(
                    title: 'Add',
                    onPressed: _isLoading ? null : _addCategory,
                  ),
                ],
              ),
            ),
    );
  }
}
