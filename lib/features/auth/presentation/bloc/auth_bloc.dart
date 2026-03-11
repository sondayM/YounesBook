import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tracker/core/errors/failures.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  final AuthRepository _authRepository;

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    await emit.forEach<UserEntity?>(
      _authRepository.authStateChanges,
      onData: (user) {
        if (user != null) {
          return AuthState.authenticated(user);
        }
        return const AuthState.unauthenticated();
      },
      onError: (_, __) => const AuthState.unauthenticated(),
    );
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      emit(AuthState.authenticated(user));
    } on Failure catch (f) {
      emit(AuthState.failure(f.message ?? 'Sign up failed'));
    }
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } on Failure catch (f) {
      emit(AuthState.failure(f.message ?? 'Sign in failed'));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onResetPassword(AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.resetPassword(event.email);
      emit(const AuthState.resetPasswordSent());
    } on Failure catch (f) {
      emit(AuthState.failure(f.message ?? 'Failed to send reset email'));
    }
  }
}
