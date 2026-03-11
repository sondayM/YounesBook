import 'package:tracker/core/errors/failures.dart';
import 'package:tracker/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthDataSource? dataSource})
      : _dataSource = dataSource ?? AuthLocalDataSourceImpl();

  final AuthDataSource _dataSource;
  UserEntity? _cachedUser;

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;

  @override
  UserEntity? get currentUser => _cachedUser ?? _dataSource.currentUser;

  void setCachedUser(UserEntity? user) {
    _cachedUser = user;
  }

  @override
  Future<UserEntity> ensureDefaultUser() async {
    final user = await _dataSource.ensureDefaultUser();
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _dataSource.signUpWithEmail(email: email, password: password, name: name);
      _cachedUser = user;
      return user;
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmail(email: email, password: password);
      _cachedUser = user;
      return user;
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
    _cachedUser = null;
    await ensureDefaultUser();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _dataSource.resetPassword(email);
  }
}
