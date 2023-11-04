import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      barrierColor: const Color.fromARGB(210, 0, 0, 0),
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are sure you want to leave?',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            icon: const Icon(
              Icons.logout,
              size: 60,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]);
      }).then((value) => value ?? false);
}
