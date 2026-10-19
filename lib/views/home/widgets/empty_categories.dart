import 'package:flutter/material.dart';
import '../../../core/widgets/empty_view.dart';

/// Placeholder shown when the current user has no categories yet.
class EmptyCategories extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onAddCategory;

  const EmptyCategories({
    super.key,
    this.title = 'No categories yet',
    this.message = 'Add your first category to start organizing notes.',
    this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.folder_copy_outlined,
      title: title,
      message: message,
      actionLabel: onAddCategory == null ? null : 'Add category',
      onAction: onAddCategory,
    );
  }
}
