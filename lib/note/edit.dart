// ignore_for_file: use_build_context_synchronously, avoid_print, body_might_complete_normally_nullable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_management_mobile_application/note/view.dart';

import '../component/TextFormFieldAdd.dart';
import '../component/customButtonAuth.dart';

class EditNote extends StatefulWidget {
  final String notedocid;
  final String categorydocid;
  final String value;

  const EditNote({
    Key? key,
    required this.notedocid,
    required this.categorydocid,
    required this.value,
  }) : super(key: key);

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  // Form key to manage the state of the form
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  // Controller for the note input field
  TextEditingController note = TextEditingController();

  // Flag to track loading state
  bool isLoading = false;

  // Function to add data to Firestore
  void editNote() async {
    // Reference to the collection in Firestore
    CollectionReference collectionNote = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.categorydocid)
        .collection("note");

    // Validate the form before proceeding
    if (formstate.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});

        // Update the note in Firestore
        await collectionNote.doc(widget.notedocid).update({
          'note': note.text,
          'id': FirebaseAuth.instance.currentUser!.uid
        });

        // Navigate to NoteView after successfully editing the note
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteView(categoryid: widget.categorydocid)));
      } catch (e) {
        isLoading = false;
        setState(() {});

        // Handle errors
        print("Error $e");
      }
    }
  }

  @override
  void initState() {
    // Set the initial value of the note from the widget's value
    note.text = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the controller to free up resources
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Edit Note"),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Form(
          key: formstate,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 25),
                child: CustomTextFormFieldAdd(
                  hintText: "Enter Your Note",
                  mycontroller: note,
                  validator: (val) {
                    if (val == "") {
                      return "Can't To be Empty";
                    }
                  },
                ),
              ),
              customButton(
                title: "Save",
                onPressed: () {
                  // Call the editNote function when the Save button is pressed
                  editNote();
                },
              ),
              Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );
  }
}
