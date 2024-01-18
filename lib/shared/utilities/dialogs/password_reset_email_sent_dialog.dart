import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content: 'Reset password link was sent.\nCheck your email to reset the password',
    optionsBuilder: () => {
      'OK': null,
    },
    icon: Icon(
      Icons.password,
      size: 60,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
