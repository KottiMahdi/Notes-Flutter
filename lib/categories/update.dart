import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../component/TextFormFieldAdd.dart';
import '../component/customButtonAuth.dart';

class UpdateCategory extends StatefulWidget {
  final String docid;
  final String oldName;

  const UpdateCategory({Key? key, required this.docid, required this.oldName})
      : super(key: key);

  @override
  State<UpdateCategory> createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  // Form key and controller
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();

  // Loading indicator flag
  bool isLoading = false;

  // Firestore collection reference
  CollectionReference categories =
  FirebaseFirestore.instance.collection('categories');

  // Function to update data in Firestore
  void editCategory() async {
    if (formstate.currentState!.validate()) {
      try {
        // Set loading indicator to true
        setState(() {
          isLoading = true;
        });

        // Update category name in Firestore
        await categories.doc(widget.docid).update({"name": name.text});

        // Navigate to the homepage and remove all previous routes
        Navigator.of(context)
            .pushNamedAndRemoveUntil('homepage', (route) => false);
      } catch (e) {
        // If an error occurs, set loading indicator to false and print the error
        setState(() {
          isLoading = false;
        });
        // ignore: avoid_print
        print("Error $e");
      }
    }
  }

  @override
  void initState() {
    // Initialize state, set the initial value of the text controller
    super.initState();
    name.text = widget.oldName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Edit Category"),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Form(
          key: formstate,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 25),
                child: CustomTextFormFieldAdd(
                  hintText: "Enter name",
                  mycontroller: name,
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
                  editCategory();
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
