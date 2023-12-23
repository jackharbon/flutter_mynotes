import 'package:flutter/foundation.dart' show immutable;

import '../auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

//  ------------------ Output states --------------------------------

// bloc state of loading
class AuthStateLoading extends AuthState {
  const AuthStateLoading({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({
    required this.user,
    required super.isLoading,
  });
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({
    required super.isLoading,
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({
    required super.isLoading,
  });
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText = null,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLogoutFailure extends AuthState {
  final Exception exception;

  const AuthStateLogoutFailure({
    required this.exception,
    required super.isLoading,
  });
}

//  ------------------ Input states --------------------------------

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required super.isLoading,
  });
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });
}
