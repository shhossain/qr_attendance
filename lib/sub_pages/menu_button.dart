import 'package:basic_flutter/sub_pages/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomMenuButton extends StatelessWidget {
  const CustomMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'login') {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(login, (route) => false);
        } else if (value == 'register') {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(register, (route) => false);
        } else if (value == 'logout') {
          await showLogout(context);
          Navigator.of(
            // ignore: use_build_context_synchronously
            context,
          ).pushNamedAndRemoveUntil(login, (route) => false);
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

Future<bool> showLogout(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login/', (route) => false);
            },
            child: const Text('Log out'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<bool> devicelost(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Notice'),
        content: const Text('Please login from your own device'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(lostdevice, (route) => false);
            },
            child: const Text('Get Help'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
