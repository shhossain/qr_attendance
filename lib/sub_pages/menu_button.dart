import 'package:flutter/material.dart';
import 'package:basic_flutter/sub_pages/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomMenuButton extends StatelessWidget {
  const CustomMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'login') {
          Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
        } else if (value == 'register') {
          Navigator.of(context).pushNamedAndRemoveUntil(register, (route) => false);
        } else if (value == 'logout') {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(value: 'login', child: Text('Login')),
          const PopupMenuItem(value: 'register', child: Text('Register')),
          const PopupMenuItem(value: 'logout', child: Text('Log out')),
        ];
      },
    );
  }
}
