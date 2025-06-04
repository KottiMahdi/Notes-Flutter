import 'package:flutter/material.dart';

class CustomTextFormFieldAdd extends StatelessWidget {
  final String hintText;
  final TextEditingController mycontroller;
  final String? Function(String?)? validator;
  const CustomTextFormFieldAdd(
      {super.key, required this.hintText, required this.mycontroller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mycontroller,
      maxLines: null,
      validator: validator,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.grey))),
    );
  }
}
