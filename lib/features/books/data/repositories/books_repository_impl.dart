import 'package:tracker/features/books/data/datasources/books_local_data_source.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';
import 'package:tracker/features/books/domain/repositories/books_repository.dart';

class BooksRepositoryImpl implements BooksRepository {
  BooksRepositoryImpl({BooksDataSource? dataSource})
      : _dataSource = dataSource ?? BooksLocalDataSourceImpl();

  final BooksDataSource _dataSource;

  @override
  Stream<List<BookEntity>> watchBooks(String userId) => _dataSource.watchBooks(userId);

  @override
  Future<List<BookEntity>> getBooks(String userId, {ReadingStatus? status, String? search}) =>
      _dataSource.getBooks(userId, status: status, search: search);

  @override
  Future<BookEntity?> getBookById(String userId, String bookId) =>
      _dataSource.getBookById(userId, bookId);

  @override
  Future<List<BookEntity>> getFavoriteBooks(String userId) =>
      _dataSource.getFavoriteBooks(userId);

  @override
  Future<BookEntity> addBook(BookEntity book, {List<int>? coverImageBytes}) =>
      _dataSource.addBook(book, coverImageBytes: coverImageBytes);

  @override
  Future<BookEntity> updateBook(BookEntity book, {List<int>? coverImageBytes}) =>
      _dataSource.updateBook(book, coverImageBytes: coverImageBytes);

  @override
  Future<void> deleteBook(String userId, String bookId) =>
      _dataSource.deleteBook(userId, bookId);

  @override
  Future<BookEntity> updateProgress(String userId, String bookId, int currentPage) =>
      _dataSource.updateProgress(userId, bookId, currentPage);

  @override
  Future<BookEntity> toggleFavorite(String userId, String bookId) =>
      _dataSource.toggleFavorite(userId, bookId);

  @override
  Future<BookEntity> addOrUpdateNote(String userId, String bookId, String noteId, String content, {String noteType = 'general'}) =>
      _dataSource.addOrUpdateNote(userId, bookId, noteId, content, noteType: noteType);

  @override
  Future<BookEntity> deleteNote(String userId, String bookId, String noteId) =>
      _dataSource.deleteNote(userId, bookId, noteId);
}
