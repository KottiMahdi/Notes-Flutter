import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import '../../utils/app_error_messages.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'note_list_view.dart';

class AddNoteView extends StatefulWidget {
  final String categoryId;
  final NoteController? noteController;

  const AddNoteView({
    super.key,
    required this.categoryId,
    this.noteController,
  });

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _noteCtrl = TextEditingController();
  late final NoteController _noteController =
      widget.noteController ?? NoteController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _noteController.addNote(widget.categoryId, _noteCtrl.text);
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NoteListView(categoryId: widget.categoryId),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorMessages.fromException(
              error,
              fallback: 'Could not add the note. Please try again.',
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
        title: const Text('Add Note'),
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
                        hintText: 'Enter Your Note',
                        mycontroller: _noteCtrl,
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
                      onPressed: _isLoading ? null : _addNote,
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
