import 'package:basic_flutter/sub_pages/device_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/sub_pages/errordialog.dart';
import 'package:basic_flutter/sub_pages/routes.dart';
import 'sub_pages/firebase_options.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _email;
  late TextEditingController _password;
  late String typeOfUser;
  late String? loginDevice;
  late String deviceId;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
        title: const Text('Login'),
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Logo
                        Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Image.asset(
                            'assets/Logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Email Field
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: false,
                          decoration: inputDecoration('Enter your email'),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          decoration: inputDecoration('Enter your password'),
                        ),
                        const SizedBox(height: 10),

                        //forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              if (_email.text.isNotEmpty) {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                      email: _email.text.trim(),
                                    );
                                if (!mounted) return;
                                await showError(
                                  context,
                                  "Password reset email sent!",
                                );
                              } else {
                                await showError(
                                  context,
                                  "Please enter your email first",
                                );
                              }
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                0,
                                161,
                                115,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final email = _email.text.trim();
                              final password = _password.text.trim();

                              try {
                                final userCredential = await FirebaseAuth
                                    .instance
                                    .signInWithEmailAndPassword(
                                      email: email,
                                      password: password,
                                    );

                                if (userCredential.user != null &&
                                    userCredential.user!.emailVerified) {
                                  // Fetch userType from Firestore
                                  final doc = await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userCredential.user!.uid)
                                      .get();

                                  typeOfUser = doc['userType'];
                                  deviceId = doc['DeviceId'];
                                  loginDevice = await getAndroidDeviceId();
                                  if (loginDevice != deviceId) {
                                    await showError(
                                      context,
                                      'Please login from your own device',
                                    );
                                  } else {
                                    if (typeOfUser == 'Student') {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        student,
                                        (route) => false,
                                      );
                                    } else if (typeOfUser == 'Teacher') {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        teacher,
                                        (route) => false,
                                      );
                                    }
                                  }
                                }
                              } on FirebaseAuthException catch (e) {
                                String message = 'Login failed';
                                if (e.code == 'invalid-credential') {
                                  message = 'Incorrect Username or Password';
                                }
                                if (!mounted) return;
                                await showError(context, message);
                              }
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromARGB(255, 0, 161, 115),
                          width: 2,
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(register, (route) => false);
                      },
                      child: const Text(
                        "Create New Account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
