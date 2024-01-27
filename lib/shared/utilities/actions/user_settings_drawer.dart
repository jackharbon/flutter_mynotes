import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/crud/notes_services.dart';
import 'popup_menu.dart';

class UserSettingsDrawer extends StatefulWidget {
  const UserSettingsDrawer({
    super.key,
  });

  @override
  State<UserSettingsDrawer> createState() => _UserSettingsDrawerState();
}
// TODO: TRANSLATIONS

class _UserSettingsDrawerState extends State<UserSettingsDrawer> {
  late final LocalNotesService _notesService;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  final getXArguments = Get.arguments;
  DatabaseUser get user => getXArguments[0]['user'];

  @override
  void initState() {
    _notesService = LocalNotesService();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        size: 28,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.grey.shade200,
                          child: const CircleAvatar(
                            radius: 62,
                            backgroundImage: AssetImage('assets/avatars/default.png'),
                          ),
                        ),
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.white,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    45,
                                  ),
                                ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(2, 4),
                                    color: Colors.black.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 3,
                                  ),
                                ]),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.add_a_photo, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    popupMenuItems(context), //Circle
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              TextField(
                controller: _firstName,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your first name here',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _lastName,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter your last name here',
                ),
              ),
            ],
          ),
          ListTile(
            title: const Text('Theme'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Color'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
