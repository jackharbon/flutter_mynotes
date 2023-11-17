import 'dart:developer' as devtools show log;
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../extensions/list/filter.dart';
import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  DatabaseUser? _user;

  // ======================== NOTE STREAM ========================

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id; // we return boolean in filter function
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  // -------------------- _cacheNotes() --------------------

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | _cacheNotes() | _notes: $_notes');
  }

// ======================== INITIALIZE DATABASE ========================

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      // ? -----------------------------------------------------------
      devtools.log(' ==> notes_services | _getDatabaseOrThrow() | db: $db');
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
      devtools.log(' ==> notes_services | close() | _db: $_db');
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
      devtools.log(' ==> notes_services | open() | dbPath: $dbPath');
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
      await _cacheNotes();
      // ? -----------------------------------------------------------
      devtools.log(' ==> notes_services | open() | createUserTable: $createUserTable');
      devtools.log(' ==> notes_services | open() | createNoteTable: $createNoteTable');
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

// ======================== NOTES CRUD ========================

  // -------------------- getNote() --------------------

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      // ? -----------------------------------------------------------
      devtools.log(' ==> notes_services | getNote() | note: $note');
      return note;
    }
  }

  // -------------------- getAllNotes() --------------------

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | getAllNotes() | notes: $notes');
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // -------------------- createNote() --------------------

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
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
    devtools.log(' ==> notes_services | createNote() | noteId: $noteId');
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      title: title,
      text: text,
      createdAt: createdAt,
      isSyncedWithCloud: true,
    );
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | createNote() | note: $note');
    _notes.add(note);
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | createNote() | _notes: $_notes');
    return note;
  }

  // -------------------- updateNote() --------------------

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String title,
    required String text,
    required String createdAt,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getNote(id: note.id);

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
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      // ? -----------------------------------------------------------
      devtools.log(' ==> notes_services | updateNote() | updatedNote: $updatedNote');
      return updatedNote;
    }
  }

  // -------------------- deleteNote() --------------------

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | deleteNote() | deletedCount: $deletedCount');
    if (deletedCount == 0) {
      throw ColdNotDeleteNoteException();
    } else {
      final countBefore = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      if (_notes.length != countBefore) {
        _notesStreamController.add(_notes);
      }
    }
  }

  // -------------------- deleteAllNotes() --------------------

  Future<int> deleteAllNotes({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final user = await getUser(email: email);
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | deleteAllNotes() | user.id: ${user.id}');
    final numberOfDeletedNotes = await db.delete(
      noteTable,
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
    _notes = [];
    _notesStreamController.add(_notes);
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | deleteAllNotes() | numberOfDeletedNotes: $numberOfDeletedNotes');
    return numberOfDeletedNotes;
  }

  // ======================== USER CRUD ========================

  // -------------------- getOrCreateUser() --------------------

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true, // set retrieved user as a current user to filter notes
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      // ? ----------------------------------------------------------------------------------
      devtools.log(' ==> notes_services | getOrCreateUser() | get _user: $_user');
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email, password: _user!.password);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      // ? ----------------------------------------------------------------------------------
      devtools.log(' ==> notes_services | getOrCreateUser() | createdUser: $createdUser');
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

// -------------------- checkUser() --------------------

  Future<DatabaseUser> logInUser({required String email, required String password}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    List<Map<String, dynamic>> results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ? and password = ?',
      whereArgs: [email, password],
    );
    // ? --------------------------------
    devtools.log(' ==> notes_services | checkUser() | results: $results');
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

// -------------------- getUser() --------------------

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | getUser() | results: $results');
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

// -------------------- createUser() --------------------

  Future<DatabaseUser> createUser({required String email, required String password}) async {
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
    devtools.log(' ==> notes_services | createUser() | userId: $userId');

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

  Future<DatabaseUser> updateIsEmailVerified({
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
      throw CouldNotUpdateNoteException();
    } else {
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      // ? -----------------------------------------------------------
      devtools.log(' ==> notes_services | updateIsEmailVerified() | results: $results');
      if (results.isEmpty) {
        throw CouldNotFindUserException();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }
  }

  // -------------------- deleteUser() --------------------

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedAccounts = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // ? -----------------------------------------------------------
    devtools.log(' ==> notes_services | deleteUser() | deletedAccounts: $deletedAccounts');
    if (deletedAccounts != 1) {
      throw ColdNotDeleteUserException();
    }
  }
}

// ======================== Note Database ========================

class DatabaseNote {
  final int id;
  final int userId;
  final String? title;
  final String text;
  final String createdAt;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
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
  bool operator ==(covariant DatabaseNote other) => id == other.id;

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

// ========================= DATABASE VARIABLES =========================

const dbName = 'notes.db';

// -------------------- Note Database --------------------

const noteTable = 'note';
const userIdColumn = 'user_id';
const titleColumn = 'title';
const textColumn = 'text';
const createdAtColumn = 'created_at';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"title"	TEXT,
	"text"	TEXT,
  "created_at"  TEXT NOT NULL,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
      );''';
// -------------------- User Database --------------------

const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const passwordColumn = 'password';
const firstNameColumn = 'first_name';
const lastNameColumn = 'last_name';
const themeModeColumn = 'theme_mode';
const colorsSchemeColumn = 'colors_scheme';
const avatarUrlColumn = 'avatar_url';
const createdAtUserColumn = 'created_at_user';
const isEmailVerifiedColumn = 'is_email_verified';

const createUserTable = '''CREATE TABLE IF NOT EXISTS  "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
  "password" TEXT NOT NULL,
	"first_name"	TEXT,
	"last_name"	TEXT,
	"theme_mode"	TEXT,
	"colors_scheme"	TEXT,
	"avatar_url"	TEXT,
  "created_at_user"  TEXT NOT NULL,
  "is_email_verified"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
      );''';
