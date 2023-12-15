import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException, GoogleAuthProvider;
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';
import 'auth_user.dart';
import 'auth_provider.dart';
import 'auth_exceptions.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'channel-error') {
        throw MissingDataAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'unknown') {
        throw UnknownAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> deleteUserAccount({
    required String email,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseAuth.instance.currentUser!.delete();
        debugPrint('|===> firebase_auth_provider | deleteAccount() | deletedAccount: $currentUser');
      } else {
        debugPrint('|===> firebase_auth_provider | deleteAccount() | currentUser is null!');
        throw ColdNotDeleteUserException();
      }
    } on FirebaseAuthException catch (e) {
      // ? --------------------------------
      debugPrint('|===> firebase_auth_provider | deleteAccount() | error: $e');
      switch (e.code) {
        case "requires-recent-login":
          FirebaseAuth.instance.currentUser!.providerData.first;
          await FirebaseAuth.instance.currentUser!.reauthenticateWithProvider(GoogleAuthProvider());
          await FirebaseAuth.instance.currentUser!.delete();
        default:
          throw ColdNotDeleteUserException();
      }
    } catch (e) {
      // ? --------------------------------
      debugPrint('|===> firebase_auth_provider | deleteAccount() | UnknownAuthException: $e');
      throw UnknownAuthException();
    }
    // ? --------------------------------
    debugPrint('|===> firebase_auth_provider | deleteAccount() | GenericAuthException');
    throw GenericAuthException();
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'channel-error') {
        throw MissingDataAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'unknown') {
        throw UnknownAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
