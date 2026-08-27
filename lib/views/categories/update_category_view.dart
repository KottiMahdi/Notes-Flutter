import 'package:flutter/material.dart';

import '../../controllers/category_controller.dart';
import '../../utils/app_error_messages.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class UpdateCategoryView extends StatefulWidget {
  final String docId;
  final String oldName;
  final CategoryController? categoryController;

  const UpdateCategoryView({
    super.key,
    required this.docId,
    required this.oldName,
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

  @override
  void initState() {
    _nameCtrl.text = widget.oldName;
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _categoryController.updateCategory(widget.docId, _nameCtrl.text);
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Edit Category'),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Form(
          key: _formKey,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 25,
                      ),
                      child: CustomTextField(
                        hintText: 'Enter name',
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
                      title: 'Save',
                      onPressed: _isLoading ? null : _updateCategory,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
