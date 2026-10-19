import 'package:flutter/material.dart';

Future<void> showRetryErrorDialog(
  BuildContext context, {
  required String message,
  required Future<void> Function() onRetry,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon:
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
      title: const Text('Something went wrong'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onRetry();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}
