import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../component/TextFormFieldAdd.dart';
import '../component/customButtonAuth.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();

  // Firestore collection reference
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  // Function to add data to Firestore
  void addCategory() async {
    if (formState.currentState!.validate()) {
      try {
        DocumentReference response = await categories.add({
          'name': name.text,'id': FirebaseAuth.instance.currentUser!.uid
        });
        Navigator.of(context)
            .pushNamedAndRemoveUntil('homepage', (route) => false);
      } catch (e) {
        print("Error $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Category"),
      ),
      body: Form(
        key: formState,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormFieldAdd(
                hintText: "Enter Name",
                mycontroller: name,
                validator: (val) {
                  if (val == "") {
                    return "Can't To be Empty";
                  }
                },
              ),
            ),
            customButton(
              title: "Add",
              onPressed: () {
                addCategory();
              },
            )
          ],
        ),
      ),
    );
  }
}
