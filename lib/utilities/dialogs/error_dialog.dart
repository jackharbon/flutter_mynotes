import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
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
      'OK': null,
    },
  );
}
