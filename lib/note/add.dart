// ignore_for_file: body_might_complete_normally_nullable, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_management_mobile_application/note/view.dart';

import '../component/TextFormFieldAdd.dart';
import '../component/customButtonAuth.dart';

class AddNote extends StatefulWidget {
  final String docid;
  const AddNote({Key? key, required this.docid}) : super(key: key);
  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  // GlobalKey is used to access the form and validate its fields.
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  // TextEditingController is used to retrieve the current value of a TextField.
  TextEditingController note = TextEditingController();

  // isLoading is a boolean variable to check if the data is being added to Firestore.
  bool isLoading = false;

  // addNote function is responsible for adding data to Firestore.
  addNote() async {
    // Get a reference to the note collection in Firestore.
    CollectionReference collectionNote = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.docid)
        .collection("note");

    // Validate the form fields.
    if (formstate.currentState!.validate()) {
      try {
        // Set isLoading to true to show a loading indicator.
        isLoading = true;
        setState(() {});

        // Add the note to Firestore.
        DocumentReference response = await collectionNote.add(
            {'note': note.text, 'id': FirebaseAuth.instance.currentUser!.uid});

        // Navigate to the NoteView page.
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteView(categoryid: widget.docid)));
      } catch (e) {
        // If an error occurs, set isLoading back to false and print the error.
        isLoading = false;
        setState(() {});
        print("Error $e");
      }
    }
  }

////
  // dispose function is used to clean up resources when the widget is removed from the widget tree.
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  // build function is used to create the widget tree.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Add Note"),
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
                  title: "Add",
                  onPressed: () {
                    addNote();
                  },
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            )),
      ),
    );
  }
}
//
//This code adds a note to a Firestore collection. The note includes the note text and the user ID. The note is added to the "note" subcollection of the "categories" collection in Firestore. The user is then navigated to the NoteView page..</s>