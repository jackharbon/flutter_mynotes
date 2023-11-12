import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<bool> toggleDatabaseSourceDialog(
  BuildContext context,
  String title,
  String content,
  Icon icon,
) {
  return showGenericDialog<bool>(
    context: context,
    title: title,
    content: content,
    icon: icon,
    optionsBuilder: () => {
      'Cancel': false,
      'Switch': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
