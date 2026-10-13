import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../controllers/note_controller.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/utils/note_content_codec.dart';
import '../../core/utils/quill_editor_utils.dart';
import 'widgets/add_link_dialog.dart';
import 'widgets/note_formatting_toolbar.dart';

class EditNoteView extends StatefulWidget {
  final String categoryId;
  final String? noteId;
  final String oldText;
  final String oldTitle;
  final NoteController? noteController;

  const EditNoteView({
    super.key,
    required this.categoryId,
    this.noteId,
    this.oldText = '',
    this.oldTitle = '',
    this.noteController,
  });

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  late final QuillController _noteCtrl;
  final TextEditingController _titleCtrl = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  late final NoteController _noteController =
      widget.noteController ?? NoteController();

  StreamSubscription<DocChange>? _contentSubscription;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl = QuillController(
      document: NoteContentCodec.decode(widget.oldText),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _titleCtrl.text = widget.oldTitle;
    _noteCtrl.addListener(_onEditorChanged);
    _contentSubscription = _noteCtrl.changes.listen((_) => _onContentChanged());
    _titleCtrl.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    unawaited(_contentSubscription?.cancel());
    _noteCtrl.removeListener(_onEditorChanged);
    _noteCtrl.dispose();
    _titleCtrl.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  String get _plainText =>
      NoteContentCodec.documentPlainText(_noteCtrl.document);

  bool get _canUndo => _noteCtrl.hasUndo;
  bool get _canRedo => _noteCtrl.hasRedo;

  void _onEditorChanged() {
    if (mounted) setState(() {});
  }

  void _onTitleChanged() {
    if (mounted) setState(() => _hasChanges = true);
  }

  void _undo() {
    if (_canUndo) _noteCtrl.undo();
  }

  void _redo() {
    if (_canRedo) _noteCtrl.redo();
  }

  void _onContentChanged() {
    if (!mounted) return;
    setState(() => _hasChanges = true);
  }

  Future<bool> _save() async {
    if (!mounted || _plainText.trim().isEmpty) return false;
    try {
      final content = NoteContentCodec.encode(_noteCtrl.document);
      final noteId = widget.noteId;
      if (noteId == null) {
        await _noteController.addNote(
          widget.categoryId,
          content,
          title: _titleCtrl.text,
        );
      } else {
        await _noteController.editNote(
          widget.categoryId,
          noteId,
          content,
          title: _titleCtrl.text,
        );
      }
      if (!mounted) return false;
      setState(() => _hasChanges = false);
      return true;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorMessages.fromException(
              error,
              fallback: 'Could not save the note. Please try again.',
            ),
          ),
        ),
      );
      return false;
    }
  }

  void _leave() => Navigator.of(context).pop(false);

  Future<void> _saveAndClose() async {
    final navigator = Navigator.of(context);
    if (!await _save() || !mounted) return;
    navigator.pop(true);
  }

  bool _isFormatActive(Attribute attribute) {
    return _noteCtrl.getSelectionStyle().attributes[attribute.key]?.value ==
        attribute.value;
  }

  void _toggleFormat(Attribute attribute) {
    final isActive = _isFormatActive(attribute);
    _noteCtrl.formatSelection(
      isActive ? Attribute.clone(attribute, null) : attribute,
    );
    _restoreEditorFocus();
  }

  void _restoreEditorFocus() {
    if (!_noteFocusNode.hasFocus) _noteFocusNode.requestFocus();
  }

  Future<void> _addLink() async {
    final existing = QuillEditorUtils.linkAtSelection(_noteCtrl);
    final result = await showDialog<LinkResult>(
      context: context,
      builder: (dialogContext) => AddLinkDialog(initialUrl: existing?.url),
    );
    if (!mounted || result == null) return;

    QuillEditorUtils.applyLink(
      controller: _noteCtrl,
      url: result.isRemove ? null : result.url,
      existingLink: existing,
    );
    _restoreEditorFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFFFB74D) : const Color(0xFFC66A00);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _leave();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFFFFCF7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 168,
          leading: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: _leave,
              ),
              IconButton(
                tooltip: 'Undo',
                icon: const Icon(Icons.undo),
                onPressed: _canUndo ? _undo : null,
              ),
              IconButton(
                tooltip: 'Redo',
                icon: const Icon(Icons.redo),
                onPressed: _canRedo ? _redo : null,
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              color: accent,
              onPressed: _hasChanges && _plainText.trim().isNotEmpty
                  ? _saveAndClose
                  : null,
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  controller: _titleCtrl,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Heading',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 24,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFEFEAE1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: QuillEditor.basic(
                    controller: _noteCtrl,
                    focusNode: _noteFocusNode,
                    config: const QuillEditorConfig(
                      expands: true,
                      padding: EdgeInsets.only(bottom: 16),
                      placeholder: 'Enter your note...',
                    ),
                  ),
                ),
              ),
              NoteFormattingToolbar(
                isDark: isDark,
                isFormatActive: _isFormatActive,
                onToggleFormat: _toggleFormat,
                hasLink: QuillEditorUtils.linkAtSelection(_noteCtrl) != null,
                onAddLink: _addLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
