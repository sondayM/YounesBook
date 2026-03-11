import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/errors/failures.dart';
import 'package:tracker/features/auth/data/models/user_model.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';

abstract class AuthDataSource {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  Future<UserEntity> ensureDefaultUser();
  Future<UserEntity> signUpWithEmail({required String email, required String password, required String name});
  Future<UserEntity> signInWithEmail({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

class AuthLocalDataSourceImpl implements AuthDataSource {
  AuthLocalDataSourceImpl({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const _keyCurrentUserId = 'current_user_id';
  static const _keyUsers = 'users';
  static const _keyPasswords = 'passwords';

  final _authController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  Future<SharedPreferences> get prefs async => _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<UserEntity> ensureDefaultUser() async {
    final p = await prefs;
    final users = _getUsersList(p);
    if (users.isNotEmpty) {
      final uid = p.getString(_keyCurrentUserId);
      if (uid != null) {
        for (final u in users) {
          if (u['id'] == uid) {
            _currentUser = UserModel.fromFirestore(u);
            _authController.add(_currentUser);
            return _currentUser!;
          }
        }
      }
      final first = users.first;
      await p.setString(_keyCurrentUserId, first['id'] as String);
      _currentUser = UserModel.fromFirestore(first);
      _authController.add(_currentUser);
      return _currentUser!;
    }
    final id = const Uuid().v4();
    final userEntity = UserModel(
      id: id,
      name: 'User',
      email: 'user@local.app',
      photoUrl: null,
      createdAt: DateTime.now(),
    );
    users.add(userEntity.toFirestore());
    await _saveUsers(p, users);
    final passwords = _getPasswordsMap(p);
    passwords[id] = '';
    await _savePasswords(p, passwords);
    await p.setString(_keyCurrentUserId, id);
    _currentUser = userEntity;
    _authController.add(userEntity);
    return userEntity;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    final c = StreamController<UserEntity?>.broadcast();
    _initStream().then((_) {
      c.add(_currentUser);
      _authController.stream.listen((e) => c.add(e));
    });
    return c.stream;
  }

  @override
  UserEntity? get currentUser => _currentUser;

  Future<void> _initStream() async {
    final p = await prefs;
    final uid = p.getString(_keyCurrentUserId);
    if (uid != null) {
      final usersJson = p.getString(_keyUsers);
      if (usersJson != null) {
        try {
          final list = jsonDecode(usersJson) as List<dynamic>;
          for (final e in list) {
            final map = Map<String, dynamic>.from(e as Map);
            if (map['id'] == uid) {
              _currentUser = UserModel.fromFirestore(map);
              _authController.add(_currentUser);
              return;
            }
          }
        } catch (_) {}
      }
    }
    _currentUser = null;
    _authController.add(null);
  }

  Map<String, String> _getPasswordsMap(SharedPreferences p) {
    final json = p.getString(_keyPasswords);
    if (json == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(json) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _savePasswords(SharedPreferences p, Map<String, String> map) async {
    await p.setString(_keyPasswords, jsonEncode(map));
  }

  List<Map<String, dynamic>> _getUsersList(SharedPreferences p) {
    final json = p.getString(_keyUsers);
    if (json == null) return [];
    try {
      return (jsonDecode(json) as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveUsers(SharedPreferences p, List<Map<String, dynamic>> list) async {
    await p.setString(_keyUsers, jsonEncode(list));
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final p = await prefs;
    final users = _getUsersList(p);
    if (users.any((u) => (u['email'] as String).toLowerCase() == email.toLowerCase())) {
      throw const AuthFailure('An account already exists with this email');
    }
    final id = const Uuid().v4();
    final userEntity = UserModel(
      id: id,
      name: name,
      email: email,
      photoUrl: null,
      createdAt: DateTime.now(),
    );
    users.add(userEntity.toFirestore());
    await _saveUsers(p, users);
    final passwords = _getPasswordsMap(p);
    passwords[id] = password;
    await _savePasswords(p, passwords);
    await p.setString(_keyCurrentUserId, id);
    _currentUser = userEntity;
    _authController.add(userEntity);
    return userEntity;
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final p = await prefs;
    final users = _getUsersList(p);
    Map<String, dynamic>? match;
    for (final u in users) {
      if ((u['email'] as String).toLowerCase() == email.toLowerCase()) {
        match = u;
        break;
      }
    }
    if (match == null) throw const AuthFailure('No user found with this email');
    final id = match['id'] as String;
    final passwords = _getPasswordsMap(p);
    if (passwords[id] != password) throw const AuthFailure('Wrong password');
    final user = UserModel.fromFirestore(match);
    await p.setString(_keyCurrentUserId, id);
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    final p = await prefs;
    await p.remove(_keyCurrentUserId);
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {
    final p = await prefs;
    final users = _getUsersList(p);
    for (final u in users) {
      if ((u['email'] as String).toLowerCase() == email.toLowerCase()) {
        return;
      }
    }
    throw const AuthFailure('No user found with this email');
  }
}
