import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share empty note!\nPlease add title or note.',
    optionsBuilder: () => {
      'OK': null,
    },
    icon: Icon(
      Icons.warning,
      size: 60,
      color: Theme.of(context).colorScheme.error,
    ),
  );
}
