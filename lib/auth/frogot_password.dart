import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late TextEditingController usernameCtrl;

  @override
  void initState() {
    usernameCtrl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reset Password",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(top: 200, right: 20, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Enter Your Email and we will send you a password reset link",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade200),
                    child: TextFormField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                                ),
                                backgroundColor: Colors.orangeAccent,
                                padding:
                                const EdgeInsets.symmetric(vertical: 13),
                              ),
                              onPressed: () async {
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                      email: usernameCtrl.text.trim());
                                  // pop up to inform me that link password reset sent to the email
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.success,
                                    animType: AnimType.rightSlide,
                                    title: 'Done',
                                    desc:
                                    'Password reset link sent! Check your email',
                                    btnOkOnPress: () {},
                                  ).show();
                                } on FirebaseAuthException catch (e) {
                                  print(e);
                                  // pop up to inform me there is an error
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.rightSlide,
                                    title: 'Error',
                                    desc:
                                    'There is no user record correspending to this identifier',
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              },
                              child: const Text(
                                "RESET PASSWORD",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ))),
    );
  }
}
