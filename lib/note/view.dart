import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'add.dart';
import 'edit.dart';

class NoteView extends StatefulWidget {
  final String categoryid;

  const NoteView({Key? key, required this.categoryid}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  bool isLoading = true;

  // List to store data retrieved from Firestore
  List<QueryDocumentSnapshot> data = [];

  // Function to get data from Firestore
  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryid)
        .collection("note")
        .get();
    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    // Fetch data from Firestore when the widget is initialized
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FloatingActionButton to add a new note
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          onPressed: () {
            // Navigate to AddNote widget when the button is pressed
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddNote(
                docid: widget.categoryid,
              ),
            ));
          },
          icon: Icon(Icons.notes),
          label: Text("Add Note"),
        ),
      ),
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          // Sign out button in the app bar
          IconButton(
            onPressed: () async {
              // Sign out the user and navigate to the login screen
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('login', (route) => false);
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: WillPopScope(
        child: isLoading == true
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, i) {
            return InkWell(
              onTap: () {
                try {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditNote(
                      notedocid: data[i].id,
                      categorydocid: widget.categoryid,
                      value: data[i]['note'],
                    ),
                  ));
                } catch (e) {
                  print("Navigation error: $e");
                }
              },
              onLongPress: () {
                // Show a confirmation dialog when a note is long-pressed
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'Delete',
                  desc: 'Are you sure ? ',
                  btnOkOnPress: () async {
                    // Delete the note from Firestore
                    await FirebaseFirestore.instance
                        .collection("categories")
                        .doc(widget.categoryid)
                        .collection("note")
                        .doc(data[i].id)
                        .delete();
                    // Refresh the NoteView widget after deletion
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NoteView(
                        categoryid: widget.categoryid,
                      ),
                    ));
                  },
                  btnCancelOnPress: () async {},
                ).show();
              },
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${data[i]['note']}")
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        onWillPop: () {
          // Navigate to the 'homepage' screen when the back button is pressed
          Navigator.of(context)
              .pushNamedAndRemoveUntil("homepage", (route) => false);
          return Future.value(false);
        },
      ),
    );
  }
}
