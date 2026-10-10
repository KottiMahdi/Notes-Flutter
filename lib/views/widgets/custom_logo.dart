import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/img/screen.png',
        height: 96,
        width: 96,
        fit: BoxFit.contain,
      ),
    );
  }
}
