// User: user-not-found
class CloudUserNotFoundAuthException implements Exception {}

// User not logged in
class UserNotLoggedInAuthException implements Exception {}

// Missing data
class CloudMissingDataAuthException implements Exception {}

// Email: invalid-email
class CloudInvalidEmailAuthException implements Exception {}

// Email: email-already-in-use
class EmailAlreadyInUseAuthException implements Exception {}

// Password: wrong-password
class CloudWrongPasswordAuthException implements Exception {}

// Password: weak-password
class WeakPasswordAuthException implements Exception {}

// Delete Account
class ColdNotDeleteUserException implements Exception {}

// Default
class CloudUnknownAuthException implements Exception {}

// Generic
class CloudGenericAuthException implements Exception {}
