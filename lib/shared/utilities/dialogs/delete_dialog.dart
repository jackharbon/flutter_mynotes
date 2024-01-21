import 'package:flutter/material.dart';
import '../../extensions/buildcontext/loc.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  // ? --------------------------------------------
  // debugPrint('|===> delete_dialog | showDeleteDialog() | context: $context');
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.dialog_delete_note_title,
    content: context.loc.dialog_delete_note_prompt,
    icon: Icon(
      Icons.delete,
      size: 60,
      color: Theme.of(context).colorScheme.error,
    ),
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
