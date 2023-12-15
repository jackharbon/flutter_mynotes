import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) {
  // ? --------------------------------------------
  debugPrint('|===> delete_dialog | showDeleteDialog() | context: $context');
  return showGenericDialog<bool>(
    context: context,
    title: 'Warning! Delete Account!',
    content: 'Are you sure you want to delete your account?\nYou will loose all notes!',
    icon: Icon(
      Icons.warning,
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
