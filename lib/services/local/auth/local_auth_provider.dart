import 'package:mynotes/services/local/auth/local_auth_user.dart';

// class for all auth providers used for register/login

// auth provider for email and password login
abstract class AuthProviderLocal {
  Future<void> initialize();
  AuthUserLocal? get currentUser;
  Future<AuthUserLocal> logIn({
    required String email,
    required String password,
  });
  Future<AuthUserLocal> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
}
