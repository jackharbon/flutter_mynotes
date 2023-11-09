import 'auth_user.dart';

// class for all auth providers used for register/login

// auth provider for email and password login
abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<AuthUser> deleteUserAccount({
    required String email,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
}
