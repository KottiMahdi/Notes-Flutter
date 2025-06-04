import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'formRegister.dart';

class registrePage  extends StatefulWidget {
  const registrePage ({super.key});

  @override
  State<registrePage > createState() => _RegistrePageState();
}

class _RegistrePageState extends State<registrePage > {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 70,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Create  An Account To Login',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 10,
              ),
              // Custom form for registration
              const MyCustomFormRegister(),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an account?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Handle the "Login" button tap
                      // ignore: avoid_print
                      print("test");
                    },
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the login page when "Login" is pressed
                        Navigator.of(context).pushReplacementNamed("login");
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );
  }
}
