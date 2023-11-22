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
