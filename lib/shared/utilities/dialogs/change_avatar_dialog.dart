import 'package:flutter/material.dart';
import '../../extensions/buildcontext/loc.dart';
import 'generic_dialog.dart';

// TODO: translation change avatar
Future<bool> changeAvatarDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Change Avatar',
    content: 'Choose an avatar or pick a photo',
    icon: Icon(
      Icons.person,
      size: 60,
      color: Theme.of(context).colorScheme.primary,
    ),
    optionsBuilder: () => {
      context.loc.cancel: false,
      'Save': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
