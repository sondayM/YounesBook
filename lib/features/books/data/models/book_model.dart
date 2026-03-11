import 'package:tracker/features/books/data/models/book_note_model.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.author,
    super.genre,
    super.description,
    required super.totalPages,
    super.coverUrl,
    required super.readingStatus,
    super.startDate,
    super.finishDate,
    super.rating,
    super.notes,
    super.currentPage,
    super.isFavorite,
    super.bookNotes,
    required super.createdAt,
    super.updatedAt,
  });

  factory BookModel.fromEntity(BookEntity entity) {
    return BookModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      author: entity.author,
      genre: entity.genre,
      description: entity.description,
      totalPages: entity.totalPages,
      coverUrl: entity.coverUrl,
      readingStatus: entity.readingStatus,
      startDate: entity.startDate,
      finishDate: entity.finishDate,
      rating: entity.rating,
      notes: entity.notes,
      currentPage: entity.currentPage,
      isFavorite: entity.isFavorite,
      bookNotes: entity.bookNotes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static ReadingStatus _statusFromString(String? v) {
    if (v == null) return ReadingStatus.wantToRead;
    switch (v) {
      case 'currentlyReading':
        return ReadingStatus.currentlyReading;
      case 'finished':
        return ReadingStatus.finished;
      default:
        return ReadingStatus.wantToRead;
    }
  }

  static String _statusToString(ReadingStatus s) {
    switch (s) {
      case ReadingStatus.wantToRead:
        return 'wantToRead';
      case ReadingStatus.currentlyReading:
        return 'currentlyReading';
      case ReadingStatus.finished:
        return 'finished';
    }
  }

  factory BookModel.fromFirestore(Map<String, dynamic> map, String id) {
    final notesList = map['bookNotes'] as List<dynamic>?;
    final bookNotes = notesList
            ?.map((e) {
              final m = Map<String, dynamic>.from(e as Map);
              return BookNoteModel.fromFirestore(m, m['id'] as String? ?? '');
            })
            .toList() ??
        [];
    return BookModel(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      genre: map['genre'] as String?,
      description: map['description'] as String?,
      totalPages: (map['totalPages'] as num).toInt(),
      coverUrl: map['coverUrl'] as String?,
      readingStatus: _statusFromString(map['readingStatus'] as String?),
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate'].toString()) : null,
      finishDate: map['finishDate'] != null ? DateTime.tryParse(map['finishDate'].toString()) : null,
      rating: map['rating'] != null ? (map['rating'] as num).toInt() : null,
      notes: map['notes'] as String?,
      currentPage: (map['currentPage'] as num?)?.toInt() ?? 0,
      isFavorite: map['isFavorite'] as bool? ?? false,
      bookNotes: bookNotes,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'totalPages': totalPages,
      'coverUrl': coverUrl,
      'readingStatus': _statusToString(readingStatus),
      'startDate': startDate?.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
      'rating': rating,
      'notes': notes,
      'currentPage': currentPage,
      'isFavorite': isFavorite,
      'bookNotes': bookNotes.map((n) => BookNoteModel.fromEntity(n).toFirestore()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
