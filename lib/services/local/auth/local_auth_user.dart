import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUserLocal {
  final String? email;
  final bool isEmailVerified;
  const AuthUserLocal({
    required this.email,
    required this.isEmailVerified,
  });
  // instance of  AuthUser
  factory AuthUserLocal.fromFirebase(FirebaseAuth.User user) => AuthUserLocal(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
