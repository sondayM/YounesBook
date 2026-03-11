import 'package:equatable/equatable.dart';

class BookNoteEntity extends Equatable {
  const BookNoteEntity({
    required this.id,
    required this.bookId,
    required this.content,
    this.noteType = 'general', // quote, thought, summary, general
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bookId;
  final String content;
  final String noteType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, bookId, content, noteType, createdAt, updatedAt];
}
