import 'package:basic_flutter/errordialog.dart';
import 'package:basic_flutter/firebase_options.dart';
import 'package:basic_flutter/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  List<bool> isSelected = [true, false]; // Default: Student selected
  String userType = "Student";

  late TextEditingController _name;
  late TextEditingController _section;
  late TextEditingController _designation;
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _cpassword;
  bool _agreeTerms = false;

  @override
  void initState() {
    _name = TextEditingController();
    _section = TextEditingController();
    _designation = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _cpassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _section.dispose();
    _designation.dispose();
    _email.dispose();
    _password.dispose();
    _cpassword.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 161, 115),
        title: const Text("Register"),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, asyncSnapshot) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Toggle Button for Student/Teacher
                  Center(
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(12),
                      isSelected: isSelected,
                      selectedColor: Colors.white,
                      color: Colors.black,
                      fillColor: const Color.fromARGB(255, 0, 161, 115),
                      textStyle: const TextStyle(fontSize: 16),
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < isSelected.length; i++) {
                            isSelected[i] = i == index;
                          }
                          userType = index == 0 ? "Student" : "Teacher";
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Student",
                            style: TextStyle(
                              fontSize: isSelected[0] ? 18 : 16,
                              fontWeight: isSelected[0]
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Teacher",
                            style: TextStyle(
                              fontSize: isSelected[1] ? 18 : 16,
                              fontWeight: isSelected[1]
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
          
                  // Name
                  TextField(
                    controller: _name,
                    enableSuggestions: true,
                    decoration: inputDecoration('Enter your Name'),
                  ),
                  const SizedBox(height: 16),
          
                  // Email
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    decoration: inputDecoration('Enter your Email'),
                  ),
                  const SizedBox(height: 16),
          
                  // Password
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    decoration: inputDecoration('Enter your Password'),
                  ),
                  const SizedBox(height: 16),
          
                  // Confirm Password
                  TextField(
                    controller: _cpassword,
                    obscureText: true,
                    enableSuggestions: false,
                    decoration: inputDecoration('Confirm Password'),
                  ),
                  const SizedBox(height: 16),
          
                  // Conditional TextField: Section or Designation
                  if (userType == "Student")
                    TextField(
                      controller: _section,
                      enableSuggestions: true,
                      decoration: inputDecoration('Enter your Section'),
                    )
                  else
                    TextField(
                      controller: _designation,
                      enableSuggestions: true,
                      decoration: inputDecoration('Enter your Designation'),
                    ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreeTerms = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "University Related",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
          
                  // Register Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color.fromARGB(255, 0, 161, 115),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        late final String password;
                        bool valid = true;
          
                        if (_password.text == _cpassword.text) {
                          password = _password.text;
                        } else {
                          await showError(context, 'Passwords do not match');
                          return;
                        }
          
                        final email = _email.text;
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) return;
                          String message;
          
                          if (e.code == 'invalid-email') {
                            valid = false;
                            message = 'Invalid Email Address';
                          } else if (e.code == 'weak-password') {
                            message = 'Weak password';
                          } else {
                            message = 'Register Failed';
                            valid = false;
                          }
          
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
          
                        if ((_password.text == _cpassword.text) &&
                            valid &&
                            _password.text.isNotEmpty) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil(login, (route) => false);
                        }
                      },
                      child: const Text('Register', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
          
                  // Login Navigation
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(login, (route) => false);
                      },
                      child: const Text(
                        'Already registered? Login here!',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
