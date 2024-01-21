import 'package:flutter/material.dart';
import '../../extensions/buildcontext/loc.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) {
  // ? --------------------------------------------
  // debugPrint('|===> delete_dialog | showDeleteDialog() | context: $context');
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.dialog_delete_account_title,
    content: context.loc.dialog_delete_account_prompt,
    icon: Icon(
      Icons.warning,
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
