import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';

abstract class BooksRepository {
  Stream<List<BookEntity>> watchBooks(String userId);
  Future<List<BookEntity>> getBooks(String userId, {ReadingStatus? status, String? search});
  Future<BookEntity?> getBookById(String userId, String bookId);
  Future<List<BookEntity>> getFavoriteBooks(String userId);
  Future<BookEntity> addBook(BookEntity book, {List<int>? coverImageBytes});
  Future<BookEntity> updateBook(BookEntity book, {List<int>? coverImageBytes});
  Future<void> deleteBook(String userId, String bookId);
  Future<BookEntity> updateProgress(String userId, String bookId, int currentPage);
  Future<BookEntity> toggleFavorite(String userId, String bookId);
  Future<BookEntity> addOrUpdateNote(String userId, String bookId, String noteId, String content, {String noteType = 'general'});
  Future<BookEntity> deleteNote(String userId, String bookId, String noteId);
}
