import 'package:flutter/material.dart';

import '../../extensions/buildcontext/loc.dart';
import 'generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.dialog_password_reset_title,
    content: context.loc.dialog_password_reset_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
    icon: Icon(
      Icons.password,
      size: 60,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
