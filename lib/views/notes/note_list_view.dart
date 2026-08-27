import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/note_controller.dart';
import '../../models/note_model.dart';
import '../../utils/app_error_messages.dart';
import 'add_note_view.dart';
import 'edit_note_view.dart';

class NoteListView extends StatefulWidget {
  final String categoryId;
  final NoteController? noteController;
  final AuthController? authController;

  const NoteListView({
    super.key,
    required this.categoryId,
    this.noteController,
    this.authController,
  });

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  late final NoteController _noteController =
      widget.noteController ?? NoteController();
  late final AuthController _authController =
      widget.authController ?? AuthController();

  bool _isLoading = true;
  bool _isSigningOut = false;
  final Set<String> _deletingNoteIds = {};
  List<NoteModel> _notes = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _fetchNotes({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final notes = await _noteController.getNotes(widget.categoryId);
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not load notes. Please try again.',
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

  Future<void> _openAddNote() async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteView(categoryId: widget.categoryId),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      _showSnackBar('Note added.');
      await _fetchNotes();
    }
  }

  Future<void> _openEditNote(NoteModel note) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditNoteView(
          categoryId: widget.categoryId,
          noteId: note.id,
          oldText: note.note,
        ),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      _showSnackBar('Note updated.');
      await _fetchNotes();
    }
  }

  Future<void> _deleteNote(String noteId) async {
    if (_deletingNoteIds.contains(noteId)) return;

    setState(() => _deletingNoteIds.add(noteId));
    try {
      await _noteController.deleteNote(widget.categoryId, noteId);
      if (!mounted) return;
      _showSnackBar('Note deleted.');
      await _fetchNotes();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        AppErrorMessages.fromException(
          error,
          fallback: 'Could not delete the note. Please try again.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingNoteIds.remove(noteId));
      }
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
          onPressed: _isLoading || _isSigningOut ? null : _openAddNote,
          icon: const Icon(Icons.notes),
          label: const Text('Add Note'),
        ),
      ),
      appBar: AppBar(
        title: const Text('Notes'),
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
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('homepage', (route) => false);
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, i) {
                  final note = _notes[i];
                  final isDeleting = _deletingNoteIds.contains(note.id);
                  return InkWell(
                    onTap: isDeleting ? null : () => _openEditNote(note),
                    onLongPress: isDeleting
                        ? null
                        : () {
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
                    child: Opacity(
                      opacity: isDeleting ? 0.6 : 1,
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(child: Text(note.note)),
                              if (isDeleting)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
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
