import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/error/app_logger.dart';
import '../../../core/widgets/scrollable_dialog_content.dart';
import '../../../core/widgets/retry_snack_bar.dart';

class LinkResult {
  final String? url;

  const LinkResult.save(String this.url);
  const LinkResult.remove() : url = null;

  bool get isRemove => url == null;
}

class AddLinkDialog extends StatefulWidget {
  final String? initialUrl;

  const AddLinkDialog({super.key, this.initialUrl});

  @override
  State<AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<AddLinkDialog> {
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
    Navigator.of(context).pop(LinkResult.save(url));
  }

  Future<void> _openLink() async {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
    var opened = false;
    if (uri != null && uri.hasAuthority) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (error, stackTrace) {
        AppLogger.error(
          'Could not open external link.',
          error: error,
          stackTrace: stackTrace,
          name: 'links',
        );
        opened = false;
      }
    }
    if (!opened && mounted) {
      showRetrySnackBar(
        context,
        message: 'Could not open this link.',
        onRetry: _openLink,
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
      child: ScrollableDialogContent(
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
                      Navigator.of(context).pop(const LinkResult.remove()),
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
                      foregroundColor: onSurface,
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
