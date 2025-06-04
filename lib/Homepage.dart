import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'categories/update.dart';
import 'note/view.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isLoading = true;

  //Put data here in this list:
  List<QueryDocumentSnapshot> data = [];
  //get data from firestore
  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed("addCategory");
          },
          icon: Icon(Icons.add),
          label: Text("Add Categorie"),
        ),
      ),
      appBar: AppBar(
        title: const Text('List of categories'),
        actions: [
          IconButton(
              onPressed: () async {
                GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn.disconnect();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('login', (route) => false);
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
          itemCount: data.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisExtent: 160),
          itemBuilder: (context, i) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        NoteView(categoryid: data[i].id)));
              },
              onLongPress: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'Alert',
                  desc: 'Select Your Choice ',
                  btnOkText: "Edit",
                  btnOkOnPress: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UpdateCategory(
                          docid: data[i].id,
                          oldName: data[i]['name'],
                        )));
                  },
                  btnCancelText: "Delete",
                  btnCancelOnPress: () async {
                    await FirebaseFirestore.instance
                        .collection("categories")
                        .doc(data[i].id)
                        .delete();
                    Navigator.of(context).pushReplacementNamed("homepage");
                  },
                ).show();
              },
              child: Card(
                  child: Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/img/notes_752326.png",
                            height: 95,
                          ),
                          Text("${data[i]['name']}")
                        ],
                      ))),
            );
          }),
    );
  }
}
