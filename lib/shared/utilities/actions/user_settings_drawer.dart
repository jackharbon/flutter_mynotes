import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/crud/notes_services.dart';
import '../dialogs/change_avatar_dialog.dart';
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
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final getXArguments = Get.arguments;
  DatabaseUser get userFromArguments => getXArguments[0]['user'];
  DatabaseUser? currentLocalDatabaseUser;
  String? firstName;
  String? lastName;

  bool isFirstNameEditMode = false;
  bool isLastNameEditMode = false;

  currentDatabaseUser(String email) async {
    currentLocalDatabaseUser = await _notesService.getLocalUser(email: email);
    firstName = currentLocalDatabaseUser!.firstName!;
    lastName = currentLocalDatabaseUser!.lastName!;
    debugPrint('|==> user_settings | currentDatabaseUser() | currentLocalDatabaseUser: $currentLocalDatabaseUser');
    debugPrint('|==> user_settings | currentDatabaseUser() | name: $firstName, $lastName');
    return currentLocalDatabaseUser;
  }

  @override
  void initState() {
    _notesService = LocalNotesService();
    currentDatabaseUser(userFromArguments.email);
    firstName = userFromArguments.firstName!;
    lastName = userFromArguments.lastName!;
    _firstNameController = TextEditingController(text: firstName ?? '');
    _lastNameController = TextEditingController(text: lastName ?? '');
    debugPrint(
        '|==> user_settings | initState() | userFromArguments: $userFromArguments, currentLocalDatabaseUser: $currentLocalDatabaseUser');
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ================= DRAWER HEADER =================
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
                        Icons.arrow_back_outlined,
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
                              child: Icon(
                                Icons.person,
                                size: 90.0,
                              )),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
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
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.black,
                                  size: 30,
                                ),
                                // tooltip: 'Change Avatar',
                                onPressed: () {
                                  setState(() {
                                    changeAvatarDialog(context);
                                  });
                                },
                              ),
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
          // ================= USER SETTINGS =================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ---------------------- First Name ----------------------
                    SizedBox(
                      width: 260,
                      child: TextField(
                        enabled: isFirstNameEditMode,
                        autofocus: true,
                        controller: _firstNameController,
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: const UnderlineInputBorder(),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: isFirstNameEditMode,
                          labelText: 'First Name',
                          hintText: 'Enter your first name',
                        ),
                      ),
                    ),
                    (!isFirstNameEditMode)
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                isFirstNameEditMode = true;
                              });
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                          )
                        : IconButton(
                            onPressed: () async {
                              await _notesService.updateLocalUserFirstName(
                                email: userFromArguments.email,
                                firstName: _firstNameController.text,
                              );
                              setState(() {
                                isFirstNameEditMode = false;
                              });
                            },
                            icon: const Icon(
                              Icons.done,
                            ),
                          ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ---------------------- Last Name ----------------------
                    SizedBox(
                      width: 260,
                      child: TextField(
                        enabled: isLastNameEditMode,
                        autofocus: true,
                        controller: _lastNameController,
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          filled: isLastNameEditMode,
                          labelText: 'Last Name',
                          hintText: 'Enter your last name',
                          border: InputBorder.none,
                          focusedBorder: const UnderlineInputBorder(),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    (!isLastNameEditMode)
                        ? IconButton(
                            onPressed: () async {
                              setState(() {
                                isLastNameEditMode = true;
                              });
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                          )
                        : IconButton(
                            onPressed: () async {
                              await _notesService.updateLocalUserLastName(
                                email: userFromArguments.email,
                                lastName: _lastNameController.text,
                              );
                              setState(() {
                                isLastNameEditMode = false;
                              });
                            },
                            icon: const Icon(
                              Icons.done,
                            ),
                          ),
                  ],
                ),
              ],
            ),
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
