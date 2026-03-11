import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, email, photoUrl, createdAt];
}
