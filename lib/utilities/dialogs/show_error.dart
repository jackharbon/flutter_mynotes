import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String error,
  String title,
) {
  return showDialog(
    barrierColor: const Color.fromARGB(180, 0, 0, 0),
    context: context,
    builder: (context) {
      return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            error,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          icon: Icon(
            Icons.person_off_rounded,
            size: 60,
            color: Theme.of(context).colorScheme.error,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ]);
    },
  );
}
