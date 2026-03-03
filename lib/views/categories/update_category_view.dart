import 'package:flutter/material.dart';
import '../../controllers/category_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class UpdateCategoryView extends StatefulWidget {
  final String docId;
  final String oldName;

  const UpdateCategoryView(
      {super.key, required this.docId, required this.oldName});

  @override
  State<UpdateCategoryView> createState() => _UpdateCategoryViewState();
}

class _UpdateCategoryViewState extends State<UpdateCategoryView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final CategoryController _categoryController = CategoryController();
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
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);
      await _categoryController.updateCategory(widget.docId, _nameCtrl.text);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('homepage', (route) => false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Edit Category"),
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
                          vertical: 20, horizontal: 25),
                      child: CustomTextField(
                        hintText: "Enter name",
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
                      title: "Save",
                      onPressed: _updateCategory,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom))
                  ],
                ),
        ),
      ),
    );
  }
}
