import 'package:flutter/material.dart';

class customLogo extends StatelessWidget {
  const customLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        height: 80,
        width: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.orange.shade300,
            borderRadius: BorderRadius.circular(70)),
        child: Image.asset(
          'assets/img/bloc-notes.png',
          height: 50,
        ),
      ),
    );
  }
}

