part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated(this.user);
  final UserEntity user;
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });
  final String email;
  final String password;
  final String name;
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested(this.email);
  final String email;
}
