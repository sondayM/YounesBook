import 'package:equatable/equatable.dart';
import 'package:tracker/features/books/domain/entities/book_note_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';

class BookEntity extends Equatable {
  const BookEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    this.genre,
    this.description,
    required this.totalPages,
    this.coverUrl,
    required this.readingStatus,
    this.startDate,
    this.finishDate,
    this.rating,
    this.notes,
    this.currentPage = 0,
    this.isFavorite = false,
    this.bookNotes = const [],
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String author;
  final String? genre;
  final String? description;
  final int totalPages;
  final String? coverUrl;
  final ReadingStatus readingStatus;
  final DateTime? startDate;
  final DateTime? finishDate;
  final int? rating; // 1-5
  final String? notes;
  final int currentPage;
  final bool isFavorite;
  final List<BookNoteEntity> bookNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  double get progressPercentage {
    if (totalPages <= 0) return 0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        author,
        genre,
        description,
        totalPages,
        coverUrl,
        readingStatus,
        startDate,
        finishDate,
        rating,
        notes,
        currentPage,
        isFavorite,
        bookNotes,
        createdAt,
        updatedAt,
      ];
}
