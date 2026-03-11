part of 'books_bloc.dart';

abstract class BooksEvent extends Equatable {
  const BooksEvent();
  @override
  List<Object?> get props => [];
}

class BooksWatchRequested extends BooksEvent {
  const BooksWatchRequested();
}

class BooksLoadRequested extends BooksEvent {
  const BooksLoadRequested({this.statusFilter, this.search});
  final ReadingStatus? statusFilter;
  final String? search;
}

class BooksAddRequested extends BooksEvent {
  const BooksAddRequested({required this.book, this.coverImageBytes});
  final BookEntity book;
  final List<int>? coverImageBytes;
}

class BooksUpdateRequested extends BooksEvent {
  const BooksUpdateRequested({required this.book, this.coverImageBytes});
  final BookEntity book;
  final List<int>? coverImageBytes;
}

class BooksDeleteRequested extends BooksEvent {
  const BooksDeleteRequested(this.bookId);
  final String bookId;
}

class BooksUpdateProgressRequested extends BooksEvent {
  const BooksUpdateProgressRequested({required this.bookId, required this.currentPage});
  final String bookId;
  final int currentPage;
}

class BooksToggleFavoriteRequested extends BooksEvent {
  const BooksToggleFavoriteRequested(this.bookId);
  final String bookId;
}

class BooksAddNoteRequested extends BooksEvent {
  const BooksAddNoteRequested({
    required this.bookId,
    required this.noteId,
    required this.content,
    this.noteType = 'general',
  });
  final String bookId;
  final String noteId;
  final String content;
  final String noteType;
}

class BooksUpdateNoteRequested extends BooksEvent {
  const BooksUpdateNoteRequested({
    required this.bookId,
    required this.noteId,
    required this.content,
    this.noteType = 'general',
  });
  final String bookId;
  final String noteId;
  final String content;
  final String noteType;
}

class BooksDeleteNoteRequested extends BooksEvent {
  const BooksDeleteNoteRequested({required this.bookId, required this.noteId});
  final String bookId;
  final String noteId;
}
