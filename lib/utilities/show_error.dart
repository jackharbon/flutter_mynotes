import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String error,
  String title,
) {
  return showDialog(
    barrierColor: const Color.fromARGB(200, 0, 0, 0),
    context: context,
    builder: (context) {
      return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            error,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          icon: const Icon(
            Icons.error_outline,
            size: 60,
          ),
          iconColor: Colors.red,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ]);
    },
  );
}
