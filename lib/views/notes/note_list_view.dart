import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/note_controller.dart';
import '../../models/note_model.dart';
import 'add_note_view.dart';
import 'edit_note_view.dart';

class NoteListView extends StatefulWidget {
  final String categoryId;

  const NoteListView({super.key, required this.categoryId});

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  final NoteController _noteController = NoteController();
  final AuthController _authController = AuthController();

  bool _isLoading = true;
  List<NoteModel> _notes = [];

  Future<void> _fetchNotes() async {
    try {
      final notes = await _noteController.getNotes(widget.categoryId);
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading notes: $e")),
      );
    }
  }

  Future<void> _signOut() async {
    await _authController.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await _noteController.deleteNote(widget.categoryId, noteId);
      _fetchNotes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  @override
  void initState() {
    _fetchNotes();
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
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddNoteView(categoryId: widget.categoryId),
            ));
          },
          icon: const Icon(Icons.notes),
          label: const Text("Add Note"),
        ),
      ),
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil("homepage", (route) => false);
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, i) {
                  final note = _notes[i];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditNoteView(
                          categoryId: widget.categoryId,
                          noteId: note.id,
                          oldText: note.note,
                        ),
                      ));
                    },
                    onLongPress: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Delete',
                        desc: 'Are you sure ? ',
                        btnOkOnPress: () => _deleteNote(note.id),
                        btnCancelOnPress: () {},
                      ).show();
                    },
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(note.note)],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
