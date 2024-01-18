import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  // ? --------------------------------------------
  // debugPrint('|===> delete_dialog | showDeleteDialog() | context: $context');
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete note',
    content: 'Are you sure you want to delete this note?',
    icon: Icon(
      Icons.delete,
      size: 60,
      color: Theme.of(context).colorScheme.error,
    ),
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
