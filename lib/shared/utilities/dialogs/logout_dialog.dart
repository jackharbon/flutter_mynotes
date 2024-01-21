import 'package:flutter/material.dart';
import '../../extensions/buildcontext/loc.dart';
import 'generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.dialog_logout_title,
    content: context.loc.dialog_logout_prompt,
    icon: Icon(
      Icons.logout,
      size: 60,
      color: Theme.of(context).colorScheme.primary,
    ),
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
