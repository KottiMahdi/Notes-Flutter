import 'package:flutter/material.dart';

void showRetrySnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onRetry,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'Retry', onPressed: onRetry),
      ),
    );
}
