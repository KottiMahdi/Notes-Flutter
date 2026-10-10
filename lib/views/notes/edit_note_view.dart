import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/note_controller.dart';
import '../../utils/app_error_messages.dart';
import '../../utils/note_content_codec.dart';

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

  ({int offset, int length, String url})? _linkAtSelection() {
    final selection = _noteCtrl.selection;
    final base = selection.start;
    final candidates = selection.isCollapsed ? [base, base - 1] : [base];
    for (final position in candidates) {
      if (position < 0 || position >= _noteCtrl.document.length) continue;
      final lineQuery = _noteCtrl.document.queryChild(position);
      final line = lineQuery.node;
      if (line is! Line) continue;
      final node = line.queryChild(lineQuery.offset, false).node;
      if (node is! Leaf) continue;
      final link = node.style.attributes[Attribute.link.key]?.value;
      if (link is String && link.isNotEmpty) {
        return (offset: node.documentOffset, length: node.length, url: link);
      }
    }
    return null;
  }

  Future<void> _addLink() async {
    final selection = _noteCtrl.selection;
    final existing = _linkAtSelection();
    final result = await showDialog<_LinkResult>(
      context: context,
      builder: (dialogContext) => _AddLinkDialog(initialUrl: existing?.url),
    );
    if (!mounted || result == null) return;

    if (existing != null) {
      _noteCtrl.formatText(
        existing.offset,
        existing.length,
        Attribute.clone(Attribute.link, result.isRemove ? null : result.url),
      );
      _restoreEditorFocus();
      return;
    }

    final url = result.url;
    if (url == null || url.isEmpty) return;

    final linkAttribute = Attribute.clone(Attribute.link, url);
    if (selection.isCollapsed) {
      final start = selection.extentOffset;
      _noteCtrl.replaceText(
        start,
        0,
        url,
        TextSelection.collapsed(offset: start + url.length),
      );
      _noteCtrl.formatText(start, url.length, linkAttribute);
    } else {
      _noteCtrl.formatText(
        selection.start,
        selection.end - selection.start,
        linkAttribute,
      );
    }
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
              _FormattingToolbar(
                isDark: isDark,
                children: [
                  _ToolbarButton(
                    icon: Icons.title,
                    tooltip: 'Heading',
                    isActive: _isFormatActive(Attribute.h1),
                    onTap: () => _toggleFormat(Attribute.h1),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    isActive: _isFormatActive(Attribute.bold),
                    onTap: () => _toggleFormat(Attribute.bold),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    isActive: _isFormatActive(Attribute.italic),
                    onTap: () => _toggleFormat(Attribute.italic),
                  ),
                  _ToolbarButton(
                    icon: Icons.link,
                    tooltip: 'Add link',
                    isActive: _linkAtSelection() != null,
                    onTap: _addLink,
                  ),
                  _ToolbarButton(
                    icon: Icons.checklist,
                    tooltip: 'Checklist',
                    isActive: _isFormatActive(Attribute.unchecked),
                    onTap: () => _toggleFormat(Attribute.unchecked),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_list_bulleted,
                    tooltip: 'Bulleted list',
                    isActive: _isFormatActive(Attribute.ul),
                    onTap: () => _toggleFormat(Attribute.ul),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Numbered list',
                    isActive: _isFormatActive(Attribute.ol),
                    onTap: () => _toggleFormat(Attribute.ol),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_quote,
                    tooltip: 'Quote',
                    isActive: _isFormatActive(Attribute.blockQuote),
                    onTap: () => _toggleFormat(Attribute.blockQuote),
                  ),
                  _ToolbarButton(
                    icon: Icons.code,
                    tooltip: 'Inline code',
                    isActive: _isFormatActive(Attribute.inlineCode),
                    onTap: () => _toggleFormat(Attribute.inlineCode),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormattingToolbar extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _FormattingToolbar({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFEFEAE1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: children),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor =
        isDark ? const Color(0xFFFFB74D) : const Color(0xFFC66A00);
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isActive
              ? activeColor.withValues(alpha: isDark ? 0.24 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                icon,
                size: 18,
                color: isActive
                    ? activeColor
                    : (onTap == null ? theme.disabledColor : null),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkResult {
  final String? url;

  const _LinkResult.save(String this.url);
  const _LinkResult.remove() : url = null;

  bool get isRemove => url == null;
}

class _AddLinkDialog extends StatefulWidget {
  final String? initialUrl;

  const _AddLinkDialog({this.initialUrl});

  @override
  State<_AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<_AddLinkDialog> {
  late final TextEditingController _urlController =
      TextEditingController(text: widget.initialUrl);

  bool get _isEditing => widget.initialUrl != null;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _save() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    Navigator.of(context).pop(_LinkResult.save(url));
  }

  Future<void> _openLink() async {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
    var opened = false;
    if (uri != null && uri.hasAuthority) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);
    final accent = isDark ? const Color(0xFFFFB74D) : const Color(0xFFC66A00);
    final onSurface = isDark ? Colors.white : const Color(0xFF17202A);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    const buttonPadding = EdgeInsets.symmetric(vertical: 14);

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.link, color: accent, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              _isEditing ? 'Edit link' : 'Add link',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isEditing
                  ? 'Update the address or remove the link.'
                  : 'Paste the address this text should open.',
              style: TextStyle(color: secondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link, color: secondary),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF7F3EC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _openLink,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text(
                    'Open link',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding: buttonPadding,
                    shape: buttonShape,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(const _LinkResult.remove()),
                  icon: const Icon(Icons.link_off, size: 18),
                  label: const Text(
                    'Remove link',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD92D20),
                    padding: buttonPadding,
                    shape: buttonShape,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: buttonPadding,
                      shape: buttonShape,
                      side: BorderSide(color: secondary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: buttonPadding,
                      shape: buttonShape,
                    ),
                    child: Text(
                      _isEditing ? 'Update' : 'Add',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
