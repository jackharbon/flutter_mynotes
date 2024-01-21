import 'package:flutter/material.dart';

import '../../extensions/buildcontext/loc.dart';
import 'generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.dialog_cannot_share_empty_note_title,
    content: context.loc.dialog_cannot_share_empty_note_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
    icon: Icon(
      Icons.warning,
      size: 60,
      color: Theme.of(context).colorScheme.error,
    ),
  );
}
