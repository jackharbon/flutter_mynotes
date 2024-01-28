import 'dart:async';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../extensions/list/filter.dart';
import 'crud_exceptions.dart';
import 'local_storage_constants.dart';

class LocalNotesService {
  Database? _db;

  List<LocalDatabaseNote> _notes = [];

  DatabaseUser? _user;

  // ======================== NOTE STREAM ========================

  static final LocalNotesService _shared = LocalNotesService._sharedInstance();
  // private initializer for NotesService
  LocalNotesService._sharedInstance() {
    _notesStreamController = StreamController<List<LocalDatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  // factory constructor for private initializer
  factory LocalNotesService() => _shared;

  late final StreamController<List<LocalDatabaseNote>> _notesStreamController;

  Stream<List<LocalDatabaseNote>> get allLocalNotesStream => _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          // ? ---------------------------------------------------------------
          debugPrint('|===> notes_services | allLocalNotesStream | currentUser: $currentUser');
          return note.userId == currentUser.id; // we return boolean in filter function
        } else {
          throw LocalUserShouldBeSetBeforeReadingAllNotes();
        }
      });

  // -------------------- _cacheNotes() --------------------130
  Future<void> _cacheLocalNotes() async {
    final allNotes = await getAllLocalNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | _cacheNotes() | _notes: $_notes');
  }

// ======================== INITIALIZE DATABASE ========================

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw LocalDatabaseIsNotOpenException();
    } else {
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | _getDatabaseOrThrow() | db: $db');
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw LocalDatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | close() | _db: $_db');
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on LocalDatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw LocalDatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | open() | dbPath: $dbPath');
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
      await _cacheLocalNotes();
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | open() | createUserTable: $createUserTable');
      // debugPrint('|===> notes_services  (shared) | open() | createNoteTable: $createNoteTable');
    } on MissingPlatformDirectoryException {
      throw LocalUnableToGetDocumentsDirectoryException();
    }
  }

// ======================== NOTES CRUD ========================

  // -------------------- getNote() --------------------
  // TODO: is it used anywhere?
  Future<LocalDatabaseNote> getLocalNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw LocalCouldNotFindLocalNoteException();
    } else {
      final note = LocalDatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | getNote() | note: $note');
      return note;
    }
  }

  // -------------------- getAllNotes() --------------------
  Future<Iterable<LocalDatabaseNote>> getAllLocalNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | getAllNotes() | notes: $notes');
    return notes.map((noteRow) => LocalDatabaseNote.fromRow(noteRow));
  }

  // -------------------- createNote() --------------------
  Future<LocalDatabaseNote> createLocalNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getLocalUser(email: owner.email);
    if (dbUser != owner) {
      throw LocalCouldNotFindUserException();
    }

    const title = '';
    const text = '';
    final createdAt = Timestamp.now().toDate().toString().substring(0, 16);
    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      textColumn: text,
      createdAtColumn: createdAt,
      isSyncedWithCloudColumn: 1,
    });
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | createNote() | noteId: $noteId');
    final note = LocalDatabaseNote(
      id: noteId,
      userId: owner.id,
      title: title,
      text: text,
      createdAt: createdAt,
      isSyncedWithCloud: false,
    );
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | createNote() | note: $note');
    _notes.add(note);
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | createNote() | _notes: $_notes');
    return note;
  }

  // -------------------- updateNote() --------------------
  Future<LocalDatabaseNote> updateLocalNote({
    required LocalDatabaseNote note,
    required String title,
    required String text,
    required String createdAt,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getLocalNote(id: note.id);

    // update DB
    final updatesCount = await db.update(
      noteTable,
      {
        titleColumn: title,
        textColumn: text,
        createdAtColumn: createdAt,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw LocalCouldNotUpdateLocalNoteException();
    } else {
      final updatedNote = await getLocalNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | updateNote() | updatedNote: $updatedNote');
      return updatedNote;
    }
  }

  // -------------------- deleteNote() --------------------
  Future<void> deleteLocalNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | deleteNote() | deletedCount: $deletedCount');
    if (deletedCount == 0) {
      throw LocalColdNotDeleteLocalNoteException();
    } else {
      final countBefore = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      if (_notes.length != countBefore) {
        _notesStreamController.add(_notes);
      }
    }
  }

  // -------------------- deleteAllNotes() --------------------
  Future<int> deleteAllLocalNotes({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final user = await getLocalUser(email: email);
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | deleteAllNotes() | user.id: ${user.id}');
    final numberOfDeletedNotes = await db.delete(
      noteTable,
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
    _notes = [];
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | deleteAllNotes() | numberOfDeletedNotes: $numberOfDeletedNotes');
    return numberOfDeletedNotes;
  }

  // ======================== USER CRUD ========================

  // -------------------- getOrCreateUser() --------------------
  Future<DatabaseUser> getOrCreateLocalUser({
    required String email,
    bool setAsCurrentUser = true, // set retrieved user as a current user to filter notes
  }) async {
    try {
      final user = await getLocalUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      // ? ----------------------------------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | getOrCreateUser() | get _user: $_user');
      return user;
    } on LocalCouldNotFindUserException {
      final createdUser = await createLocalUser(email: email, password: _user!.password);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      // ? ----------------------------------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | getOrCreateUser() | createdUser: $createdUser');
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

// -------------------- checkUser() --------------------
  Future<DatabaseUser> logInLocalUser({
    required String email,
    required String password,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    if (email.isEmpty || password.isEmpty) {
      // ? --------------------------------
      // debugPrint('|===> notes_services  (shared) | logInUser() | missing data');
      throw LocalMissingDataAuthException();
    } else if (email.isNotEmpty && !regex.hasMatch(email)) {
      // ? --------------------------------
      // debugPrint('|===> notes_services  (shared) | logInUser() | invalid email');
      throw LocalInvalidEmailAuthException();
    }
    await getLocalUser(email: email);
    // ? --------------------------------
    // debugPrint('|===> notes_services  (shared) | logInUser() | user: $user');
    List<Map<String, dynamic>> results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ? and password = ?',
      whereArgs: [email, password],
    );
    if (results.isEmpty) {
      // ? --------------------------------
      // debugPrint('|===> notes_services  (shared) | logInUser() | wrong password');
      throw LocalWrongPasswordAuthException();
    } else {
      // ? --------------------------------
      // debugPrint('|===> notes_services  (shared) | logInUser() | results: $results');
      return DatabaseUser.fromRow(results.first);
    }
  }

// -------------------- getUser() --------------------
  Future<DatabaseUser> getLocalUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | getUser() | results: $results');
    if (results.isEmpty) {
      throw LocalCouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

// -------------------- createUser() --------------------
  Future<DatabaseUser> createLocalUser({required String email, required String password}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw LocalUserAlreadyExistException();
    }

    String firstName = '';
    String lastName = '';
    String themeMode = ThemeMode.system.toString();
    String flexScheme = FlexScheme.blueM3.toString();
    String avatarUrl = '';
    const isEmailVerified = 0;
    final createdAtUser = Timestamp.now().toDate().toString().substring(0, 16);

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
      passwordColumn: password,
      firstNameColumn: firstName,
      lastNameColumn: lastName,
      themeModeColumn: themeMode,
      flexSchemeColumn: flexScheme,
      avatarUrlColumn: avatarUrl.toLowerCase(),
      createdAtUserColumn: createdAtUser,
      isEmailVerifiedColumn: isEmailVerified,
    });
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | createUser() | userId: $userId');

    return DatabaseUser(
      id: userId,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      themeMode: themeMode,
      flexScheme: flexScheme,
      avatarUrl: avatarUrl,
      createdAtUser: createdAtUser,
      isEmailVerified: false,
    );
  }

  // -------------------- updateUser() --------------------
  Future<DatabaseUser> updateLocalUserFirstName({
    required String firstName,
    required String email,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // update DB
    final updatesCount = await db.update(
      userTable,
      {
        firstNameColumn: firstName,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    if (updatesCount == 0) {
      throw LocalCouldNotUpdateLocalNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      debugPrint('|===> notes_services  (shared) | updateLocalUserFirstName() | results: $results');
      if (results.isEmpty) {
        throw LocalCouldNotFindUserException();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }
  }

  Future<DatabaseUser> updateLocalUserLastName({
    required String lastName,
    required String email,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // update DB
    final updatesCount = await db.update(
      userTable,
      {
        lastNameColumn: lastName,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    if (updatesCount == 0) {
      throw LocalCouldNotUpdateLocalNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      debugPrint('|===> notes_services  (shared) | updateLocalUserLastName() | results: $results');
      if (results.isEmpty) {
        throw LocalCouldNotFindUserException();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }
  }

  Future<DatabaseUser> updateLocalUserFlexScheme({
    required String flexScheme,
    required String email,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // update DB
    final updatesCount = await db.update(
      userTable,
      {
        flexSchemeColumn: flexScheme,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    if (updatesCount == 0) {
      throw LocalCouldNotUpdateLocalNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | updateLocalUserFlexScheme() | results: $results');
      if (results.isEmpty) {
        throw LocalCouldNotFindUserException();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }
  }

  Future<DatabaseUser> updateLocalUserThemeMode({
    required String themeMode,
    required String email,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // update DB
    final updatesCount = await db.update(
      userTable,
      {
        themeModeColumn: themeMode,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    if (updatesCount == 0) {
      throw LocalCouldNotUpdateLocalNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | updateLocalUserThemeMode() | results: $results');
      if (results.isEmpty) {
        throw LocalCouldNotFindUserException();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }
  }

  Future<DatabaseUser> updateLocalUserIsEmailVerified({
    required String email,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // update DB
    final updatesCount = await db.update(
      userTable,
      {
        isEmailVerifiedColumn: 1,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    if (updatesCount == 0) {
      throw LocalCouldNotUpdateLocalNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      // debugPrint('|===> notes_services  (shared) | updateIsEmailVerified() | results: $results');
      if (results.isEmpty) {
        throw LocalCouldNotFindUserException();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }
  }

  // -------------------- deleteUser() --------------------
  Future<void> deleteLocalUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedAccounts = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // ? -----------------------------------------------------------
    // debugPrint('|===> notes_services  (shared) | deleteUser() | deletedAccounts: $deletedAccounts');
    if (deletedAccounts != 1) {
      throw LocalCouldNotDeleteUserException();
    }
  }
}

// ======================== Note Database ========================

class LocalDatabaseNote {
  final int id;
  final int userId;
  final String? title;
  final String text;
  final String createdAt;
  final bool isSyncedWithCloud;

  LocalDatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.isSyncedWithCloud,
  });

  LocalDatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        text = map[textColumn] as String,
        createdAt = map[createdAtColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, title = $title, text = $text, createdAt: $createdAt, isSyncedWithCloud = $isSyncedWithCloud,';

  @override
  bool operator ==(covariant LocalDatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ========================== User Database ==========================

// @immutable
class DatabaseUser {
  final int id;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? themeMode;
  final String? flexScheme;
  final String? avatarUrl;
  final String createdAtUser;
  final bool isEmailVerified;

  DatabaseUser({
    this.firstName,
    this.lastName,
    this.themeMode,
    this.flexScheme,
    this.avatarUrl,
    required this.createdAtUser,
    required this.id,
    required this.email,
    required this.password,
    required this.isEmailVerified,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String,
        password = map[passwordColumn] as String,
        firstName = map[firstNameColumn] as String,
        lastName = map[lastNameColumn] as String,
        themeMode = map[themeModeColumn] as String,
        flexScheme = map[flexSchemeColumn] as String,
        avatarUrl = map[avatarUrlColumn] as String,
        createdAtUser = map[createdAtUserColumn] as String,
        isEmailVerified = (map[isEmailVerifiedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Person, ID = $id, email = $email, password: $password,firstName: $firstName, lastName: $lastName, themeMode: $themeMode, colorsScheme: $flexScheme, avatarUrl: $avatarUrl, createdAtUser: $createdAtUser, isEmailVerified: $isEmailVerified';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
