part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure, resetPasswordSent }

class AuthState extends Equatable {
  const AuthState._({this.status = AuthStatus.initial, this.user, this.message});

  const AuthState.initial() : this._();
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(UserEntity u) : this._(status: AuthStatus.authenticated, user: u);
  const AuthState.failure(String m) : this._(status: AuthStatus.failure, message: m);
  const AuthState.resetPasswordSent() : this._(status: AuthStatus.resetPasswordSent);

  final AuthStatus status;
  final UserEntity? user;
  final String? message;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  @override
  List<Object?> get props => [status, user, message];
}
