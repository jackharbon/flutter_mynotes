import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });
  // instance of  AuthUser
  factory AuthUser.fromFirebase(FirebaseAuth.User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailVerified: user.emailVerified,
      );
}
