import 'package:mynotes/services/local/auth/local_auth_provider.dart';
import 'package:mynotes/services/local/auth/local_auth_user.dart';
import 'package:mynotes/services/local/auth/firebase_auth_provider.dart';

// service can deliver more providers and logic than one authProvider
class AuthServiceLocal implements AuthProviderLocal {
  final AuthProviderLocal provider;

  const AuthServiceLocal(this.provider);

  factory AuthServiceLocal.firebase() => AuthServiceLocal(
        FirebaseAuthProvider(),
      );

  @override
  Future<AuthUserLocal> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUserLocal? get currentUser => provider.currentUser;

  @override
  Future<AuthUserLocal> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();
}
