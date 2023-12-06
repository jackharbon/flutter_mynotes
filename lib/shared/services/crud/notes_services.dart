//  import 'dart:developer' as devtools show log;

import 'dart:async';
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
  LocalNotesService._sharedInstance() {
    _notesStreamController = StreamController<List<LocalDatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory LocalNotesService() => _shared;

  late final StreamController<List<LocalDatabaseNote>> _notesStreamController;

  Stream<List<LocalDatabaseNote>> get allLocalNotesStream => _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id; // we return boolean in filter function
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  // -------------------- _cacheNotes() --------------------

  Future<void> _cacheLocalNotes() async {
    final allNotes = await getAllLocalNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    //  devtools.log(' ==> notes_services  (shared) | _cacheNotes() | _notes: $_notes');
  }

// ======================== INITIALIZE DATABASE ========================

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | _getDatabaseOrThrow() | db: $db');
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | close() | _db: $_db');
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | open() | dbPath: $dbPath');
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
      await _cacheLocalNotes();
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | open() | createUserTable: $createUserTable');
      //  devtools.log(' ==> notes_services  (shared) | open() | createNoteTable: $createNoteTable');
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
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
      throw CouldNotFindLocalNoteException();
    } else {
      final note = LocalDatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | getNote() | note: $note');
      return note;
    }
  }

  // -------------------- getAllNotes() --------------------
  // TODO: is it used anywhere?
  Future<Iterable<LocalDatabaseNote>> getAllLocalNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    // ? -----------------------------------------------------------
    //  devtools.log(' ==> notes_services  (shared) | getAllNotes() | notes: $notes');
    return notes.map((noteRow) => LocalDatabaseNote.fromRow(noteRow));
  }

  // -------------------- createNote() --------------------

  Future<LocalDatabaseNote> createLocalNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getLocalUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
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
    //  devtools.log(' ==> notes_services  (shared) | createNote() | noteId: $noteId');
    final note = LocalDatabaseNote(
      id: noteId,
      userId: owner.id,
      title: title,
      text: text,
      createdAt: createdAt,
      isSyncedWithCloud: false,
    );
    // ? -----------------------------------------------------------
    //  devtools.log(' ==> notes_services  (shared) | createNote() | note: $note');
    _notes.add(note);
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    //  devtools.log(' ==> notes_services  (shared) | createNote() | _notes: $_notes');
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
      throw CouldNotUpdateLocalNoteException();
    } else {
      final updatedNote = await getLocalNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | updateNote() | updatedNote: $updatedNote');
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
    //  devtools.log(' ==> notes_services  (shared) | deleteNote() | deletedCount: $deletedCount');
    if (deletedCount == 0) {
      throw ColdNotDeleteLocalNoteException();
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
    //  devtools.log(' ==> notes_services  (shared) | deleteAllNotes() | user.id: ${user.id}');
    final numberOfDeletedNotes = await db.delete(
      noteTable,
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
    _notes = [];
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    //  devtools.log(' ==> notes_services  (shared) | deleteAllNotes() | numberOfDeletedNotes: $numberOfDeletedNotes');
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
      //  devtools.log(' ==> notes_services  (shared) | getOrCreateUser() | get _user: $_user');
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createLocalUser(email: email, password: _user!.password);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      // ? ----------------------------------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | getOrCreateUser() | createdUser: $createdUser');
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

// -------------------- checkUser() --------------------

  Future<DatabaseUser> logInLocalUser({required String email, required String password}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    List<Map<String, dynamic>> results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ? and password = ?',
      whereArgs: [email, password],
    );
    // ? --------------------------------
    //  devtools.log(' ==> notes_services  (shared) | logInUser() | results: $results');
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
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
    //  devtools.log(' ==> notes_services  (shared) | getUser() | results: $results');
    if (results.isEmpty) {
      throw CouldNotFindUserException();
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
      throw UserAlreadyExistException();
    }

    const firstName = '';
    const lastName = '';
    const themeMode = 'ThemeMode.system';
    const colorsScheme = 'FlexScheme.blueM3';
    const avatarUrl = '';
    const isEmailVerified = 0;
    final createdAtUser = Timestamp.now().toDate().toString().substring(0, 16);

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
      passwordColumn: password,
      firstNameColumn: firstName,
      lastNameColumn: lastName,
      themeModeColumn: themeMode,
      colorsSchemeColumn: colorsScheme,
      avatarUrlColumn: avatarUrl.toLowerCase(),
      createdAtUserColumn: createdAtUser,
      isEmailVerifiedColumn: isEmailVerified,
    });
    // ? -----------------------------------------------------------
    //  devtools.log(' ==> notes_services  (shared) | createUser() | userId: $userId');

    return DatabaseUser(
      id: userId,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      themeMode: themeMode,
      colorsScheme: colorsScheme,
      avatarUrl: avatarUrl,
      createdAtUser: createdAtUser,
      isEmailVerified: false,
    );
  }

  // -------------------- updateUser() --------------------

  Future<DatabaseUser> updateLocalUser({
    String? password,
    String? firstName,
    String? lastName,
    String? themeMode,
    String? colorsScheme,
    String? avatarUrl,
    required String email,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // update DB
    final updatesCount = await db.update(
      userTable,
      {
        passwordColumn: password,
        firstNameColumn: firstName,
        lastNameColumn: lastName,
        themeModeColumn: themeMode,
        colorsSchemeColumn: colorsScheme,
        avatarUrlColumn: avatarUrl,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateLocalNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | updateUser() | results: $results');
      if (results.isEmpty) {
        throw CouldNotFindUserException();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }
  }

  Future<DatabaseUser> updateLocalIsEmailVerified({
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
      throw CouldNotUpdateLocalNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      //  devtools.log(' ==> notes_services  (shared) | updateIsEmailVerified() | results: $results');
      if (results.isEmpty) {
        throw CouldNotFindUserException();
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
    //  devtools.log(' ==> notes_services  (shared) | deleteUser() | deletedAccounts: $deletedAccounts');
    if (deletedAccounts != 1) {
      throw CouldNotDeleteUserException();
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
  final String? colorsScheme;
  final String? avatarUrl;
  final String createdAtUser;
  final bool isEmailVerified;

  DatabaseUser({
    this.firstName,
    this.lastName,
    this.themeMode,
    this.colorsScheme,
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
        colorsScheme = map[colorsSchemeColumn] as String,
        avatarUrl = map[avatarUrlColumn] as String,
        createdAtUser = map[createdAtUserColumn] as String,
        isEmailVerified = (map[isEmailVerifiedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Person, ID = $id, email = $email, password: $password,firstName: $firstName, lastName: $lastName, themeMode: $themeMode, colorsScheme: $colorsScheme, avatarUrl: $avatarUrl, createdAtUser: $createdAtUser, isEmailVerified: $isEmailVerified';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
