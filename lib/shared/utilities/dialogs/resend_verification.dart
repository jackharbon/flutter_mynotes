import 'package:flutter/material.dart';
import '../../extensions/buildcontext/loc.dart';
import 'generic_dialog.dart';

Future<void> showSentEmailConfirmationDialog(
  BuildContext context,
  String content,
  String title,
  Icon icon,
) {
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: content,
    icon: icon,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
