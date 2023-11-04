import 'package:flutter/material.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
        ),
        actions: [
          popupMenuItems(context),
        ],
      ),
      body: const Text('My Notes View'),
    );
  }
}
