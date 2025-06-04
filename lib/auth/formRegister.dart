// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Define a custom Form widget.
class MyCustomFormRegister extends StatefulWidget {
  const MyCustomFormRegister({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

//---------------Text Controllers---------------
class MyCustomFormState extends State<MyCustomFormRegister> {
  late TextEditingController usernameCtrl;
  late TextEditingController passwordCtrl;
  late TextEditingController ConfirmPassword;
  late TextEditingController nameCtrls;

  bool isobscured = true;

  Future addUserDetails(String Username, String Email) async {
    await FirebaseFirestore.instance.collection('Users').add({
      'Username': Username,
      'Email': Email,
    });
  }

  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
    ConfirmPassword = TextEditingController();
    nameCtrls = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    ConfirmPassword.dispose();
    nameCtrls.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //---------------Username TextField---------------
          const Text(
            'Username',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: nameCtrls,
              cursorColor: const Color.fromRGBO(0, 197, 105, 1),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please choose a username to use';
                } else if (value.length < 4) {
                  return 'short username. choose a username with 4 or more characters ';
                }
                return null;
              },
              decoration: InputDecoration(
                  hintText: 'Enter Your Username',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: Colors.grey)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: Colors.grey)))),
          const SizedBox(
            height: 20,
          ),
          //---------------Email TextField---------------
          const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: usernameCtrl,
              style: const TextStyle(
                color: Colors.black,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                } else if (!value.contains("@") || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: InputDecoration(
                  hintText: 'Enter Your Email',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: Colors.grey)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: Colors.grey)))),
          const SizedBox(
            height: 20,
          ),
          //---------------Password TextField---------------
          const Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: passwordCtrl,
            obscureText: isobscured,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              } else if (value.length < 5) {
                return "Length of password's characters must be 5 or greater";
              }
              return null;
            },
            style: const TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
                suffixIcon: TextButton(
                    onPressed: () {
                      setState(() {
                        isobscured = !isobscured;
                      });
                    },
                    child: Text(
                      isobscured ? 'SHOW' : 'HIDE',
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    )),
                hintText: 'Enter Your Password',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.grey))),
          ),
          const SizedBox(
            height: 20,
          ),
          //---------------Confirm Password TextField---------------
          const Text(
            'Confirm Password',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            obscureText: isobscured,
            controller: ConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-enter your password';
              } else if (value.length < 5) {
                return "Length of password's characters must be 5 or greater";
              }
              print(passwordCtrl.text);
              print(ConfirmPassword.text);
              if (passwordCtrl.text != ConfirmPassword.text) {
                return "Password does not match";
              }
              return null;
            },
            style: const TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
                suffixIcon: TextButton(
                    onPressed: () {
                      setState(() {
                        isobscured = !isobscured;
                      });
                    },
                    child: Text(
                      isobscured ? 'SHOW' : 'HIDE',
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    )),
                hintText: 'Confirm Your Password',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.grey))),
          ),
          const SizedBox(
            height: 20,
          ),
          //--------------Button SIGN UP--------------
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    // 1:Create an account directly from the app connected with firebase:
                    try {
                      if (passwordCtrl.text == ConfirmPassword.text) {
                        // ignore: unused_local_variable
                        final credential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: usernameCtrl.text.trim(),
                          password: passwordCtrl.text.trim(),
                        );
                        addUserDetails(
                            nameCtrls.text.trim(), usernameCtrl.text.trim());
                      }

                      //2:Send a code to your email to verifey it
                      FirebaseAuth.instance.currentUser!
                          .sendEmailVerification();
                      //3:after create email  and send code we go to the page login
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Done',
                        desc:
                        'Email verification sent. Please check your email.',
                        btnOkOnPress: () {
                          Navigator.of(context).pushReplacementNamed("login");
                        },
                      ).show();

                      // Navigator.of(context).pushReplacementNamed("login");
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error',
                          desc: 'The password provided is too weak.',
                          btnOkOnPress: () {},
                        ).show();
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error',
                          desc: 'The account already exists for that email.',
                          btnOkOnPress: () {},
                        ).show();
                      }
                    } catch (e) {
                      print(e);
                    }
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
