// ignore: depend_on_referenced_packages
import 'package:basic_flutter/errordialog.dart';
import 'package:basic_flutter/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

class Register1 extends StatefulWidget {
  const Register1({super.key});

  @override
  State<Register1> createState() => _Register1State();
}

class _Register1State extends State<Register1> {
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _cpassword;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _cpassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _cpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 161, 115),
        title: const Text('Register'),
      ),

      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ), //important for firebase login info.,
        builder: (context, asyncSnapshot) {
          return Column(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                decoration: InputDecoration(hintText: 'Enter your email'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                decoration: InputDecoration(hintText: 'Enter your password'),
              ),
              TextField(
                controller: _cpassword,
                obscureText: true,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: 'Enter your password again',
                ),
              ),
              TextButton(
                onPressed: () async {
                  late final password;
                  bool valid = true;
                  if (_password.text == _cpassword.text) {
                    password = _password.text;
                  } else {
                    await showError(context, 'Password do not match');
                  }
                  final email = _email.text;
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'invalid-email') {
                      valid = false;
                      await showError(context, 'Invalid Email Address');
                    } else if (e.code == 'weak-password') {
                      await showError(context, 'Weak password');
                    } else {
                      await showError(context, 'Email Already in use');
                      valid =false;
                    }
                  }

                  if ((_password.text == _cpassword.text) &&
                      (valid) &&
                      (_password.text.isNotEmpty)) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(login, (route) => false);
                  }
                },
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(login, (route) => false);
                },
                child: Text('Already registered? Login here!'),
              ),
            ],
          );
        },
      ),
    );
  }
}
