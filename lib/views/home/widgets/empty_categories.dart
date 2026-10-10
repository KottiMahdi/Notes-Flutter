import 'package:flutter/material.dart';

/// Placeholder shown when the current user has no categories yet.
class EmptyCategories extends StatelessWidget {
  final String title;
  final String message;

  const EmptyCategories({
    super.key,
    this.title = 'No categories yet',
    this.message = 'Add your first category to start organizing notes.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_copy_outlined,
                size: 56, color: Colors.orange),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
