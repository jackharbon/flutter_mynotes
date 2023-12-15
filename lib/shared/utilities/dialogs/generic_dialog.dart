import 'package:flutter/material.dart';

// Type Definition: List of text buttons with String to display and optional value T
typedef DialogOptionBuilder<T> = Map<String, T?> Function();

// Future of buttons with optional value T
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String content,
  required String title,
  required Icon icon,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    barrierColor: const Color.fromARGB(180, 0, 0, 0),
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: icon,
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        actions: options.keys.map((optionTitle) {
          // every key from the map 'option' is the title
          final value = options[optionTitle];
          return TextButton(
              onPressed: () {
                if (value != null) {
                  // ? --------------------------------------------
                  debugPrint('|===> generic_dialog | showDialog() | value not-null: $value');
                  Navigator.of(context).pop(value);
                } else {
                  // ? --------------------------------------------
                  debugPrint('|===> generic_dialog | showDialog() | value null: $value');
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                optionTitle,
                style: (value == false)
                    ? TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
              ));
        }).toList(), // 'toList()' converts iterable map to list
      );
    },
  );
}
