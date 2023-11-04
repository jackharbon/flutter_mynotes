import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });
  // instance of  AuthUser
  factory AuthUser.fromFirebase(firebaseAuth.User user) => AuthUser(
        email: user.email!,
        isEmailVerified: user.emailVerified,
      );
}