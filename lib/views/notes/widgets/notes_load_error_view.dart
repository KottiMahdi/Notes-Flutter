import 'package:flutter/material.dart';
import '../../../core/widgets/error_view.dart';

class NotesLoadErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NotesLoadErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(message: message, onRetry: onRetry);
  }
}
