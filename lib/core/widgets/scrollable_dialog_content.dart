import 'package:flutter/material.dart';

class ScrollableDialogContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxHeightFactor;

  const ScrollableDialogContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.maxHeightFactor = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
      ),
      child: SingleChildScrollView(
        padding: padding,
        child: child,
      ),
    );
  }
}
