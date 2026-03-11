import 'package:tracker/features/books/domain/entities/book_note_entity.dart';

class BookNoteModel extends BookNoteEntity {
  const BookNoteModel({
    required super.id,
    required super.bookId,
    required super.content,
    super.noteType,
    required super.createdAt,
    super.updatedAt,
  });

  factory BookNoteModel.fromEntity(BookNoteEntity entity) {
    return BookNoteModel(
      id: entity.id,
      bookId: entity.bookId,
      content: entity.content,
      noteType: entity.noteType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory BookNoteModel.fromFirestore(Map<String, dynamic> map, String id) {
    return BookNoteModel(
      id: id,
      bookId: map['bookId'] as String,
      content: map['content'] as String,
      noteType: map['noteType'] as String? ?? 'general',
      createdAt: DateTime.parse(map['createdAt'].toString()),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'bookId': bookId,
      'content': content,
      'noteType': noteType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
