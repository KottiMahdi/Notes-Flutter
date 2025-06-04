// ignore: file_names
import 'package:flutter/material.dart';

class customButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  const customButton({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        height: 45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.orangeAccent,
        textColor: Colors.white,
        onPressed: onPressed,
        child: Text(title));
  }
}
