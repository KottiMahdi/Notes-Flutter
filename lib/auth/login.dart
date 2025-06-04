import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../component/customLogoAuth.dart';
import 'formLogin.dart';
//import 'package:google_sign_in/google_sign_in.dart';

// ignore: camel_case_types
class login_page extends StatefulWidget {
  const login_page({super.key});

  @override
  State<login_page> createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {


  //--------------Sign in with Google--------------
  Future signInWithGoogle(BuildContext context) async {
    try {
      print("Starting Google Sign In process");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      /* if user click sign in with google and then cancel  with this code will
    stop the rest of this function sign in with google */
      if (googleUser == null) {
        print("Google Sign In was canceled by user");
        return;
      }

      print("Google Sign In successful for: ${googleUser.email}");

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      print("Obtained Google authentication");

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print("Created Google Auth credential");

      // Once signed in, return the UserCredential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print("Firebase sign-in successful for user: ${userCredential.user?.email}");

      // Add a small delay before navigation to ensure Firebase operations complete
      await Future.delayed(Duration(milliseconds: 500));

      print("Attempting navigation to homepage");
      Navigator.of(context).pushNamedAndRemoveUntil('homepage', (route) => false);
      print("Navigation should have occurred");

    } catch (e) {
      print("Error in Google Sign In: $e");
      // You might want to show a snackbar or dialog here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const customLogo(),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Login To Continue Using The App',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //-----------------Input Form Email & Password-----------------
                    MyCustomFormLogin(),
                    //-------------------------------------------------------------
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: const Text(
                        'OR',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    //-----------------Button Login with Google-----------------
                    MaterialButton(
                        height: 45,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.grey.shade100,
                        textColor: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/img/google-color-svgrepo-com.png',
                                width: 26),
                            const Text(' Login with Google'),
                          ],
                        ),
                        onPressed: () async {
                          await signInWithGoogle(context);
                        }),

                    //-----------------------------------------------------
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed("registre");
                      },
                      child: const Center(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: "Don't Have An Account ? "),
                          TextSpan(
                              text: "Register",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ))
                        ])),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
                  ],
                ))),
      ),
    );
  }
}
