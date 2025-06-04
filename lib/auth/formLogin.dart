import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


// Define a custom Form widget.
class MyCustomFormLogin extends StatefulWidget {
  const MyCustomFormLogin({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomFormLogin> {
  late TextEditingController usernameCtrl;
  late TextEditingController passwordCtrl;
  bool isobscured = true;

  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameCtrl.text.trim(), password: passwordCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                      borderSide: const BorderSide(color: Colors.grey)))),
          //---------------Button Forgot Password ?---------------
          Container(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed("forgotPWD");
              },
              child: const Text(
                'Forgot Password ?',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
          //------------------------------------------------------
          //---------------------Button Login---------------------
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: signIn,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      // Login with email and password from firebase
                      try {
                        final credential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                            email: usernameCtrl.text.trim(),
                            password: passwordCtrl.text.trim());

                        //We check first if the email verified or not before loging into homepage
                        if (credential.user!.emailVerified) {
                          Navigator.of(context)
                              .pushReplacementNamed("homepage");
                        } else {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc: 'Please verify your email first',
                            btnOkOnPress: () {},
                          ).show();
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                          //POP UP to show me if there is an error in email
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc: 'No user found for that email.',
                            btnOkOnPress: () {},
                          ).show();
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                          //POP UP to show me if there is an error in password
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc: 'Wrong password provided for that user.',
                            btnOkOnPress: () {},
                          ).show();
                        }
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
              ),
            ],
          ),
          //------------------------------------------------------
        ],
      ),
    );
  }
}
