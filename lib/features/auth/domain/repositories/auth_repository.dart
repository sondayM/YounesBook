import 'package:tracker/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;

  Future<UserEntity> ensureDefaultUser();

  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<void> resetPassword(String email);
}
