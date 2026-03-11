import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/errors/failures.dart';
import 'package:tracker/features/books/data/models/book_model.dart';
import 'package:tracker/features/books/data/models/book_note_model.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';

abstract class BooksDataSource {
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

class BooksLocalDataSourceImpl implements BooksDataSource {
  BooksLocalDataSourceImpl({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const _keyBooks = 'books';
  final _booksController = StreamController<List<BookEntity>>.broadcast();
  List<BookModel> _cache = [];

  Future<SharedPreferences> get prefs async => _prefs ??= await SharedPreferences.getInstance();

  Future<void> _loadCache() async {
    if (_cache.isNotEmpty) return;
    final p = await prefs;
    final json = p.getString(_keyBooks);
    if (json == null || json.isEmpty) {
      _cache = [];
      return;
    }
    try {
      final list = jsonDecode(json) as List<dynamic>;
      _cache = list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['id'] = map['id'] ?? '';
        return BookModel.fromFirestore(map, map['id'] as String);
      }).toList();
    } catch (_) {
      _cache = [];
    }
  }

  Future<void> _persist() async {
    final p = await prefs;
    final list = _cache.map((b) {
      final m = b.toFirestore();
      m['id'] = b.id;
      return m;
    }).toList();
    await p.setString(_keyBooks, jsonEncode(list));
    _booksController.add(_cache);
  }

  List<BookEntity> _filterByUser(String userId) =>
      _cache.where((b) => b.userId == userId).toList();

  @override
  Stream<List<BookEntity>> watchBooks(String userId) {
    return Stream.fromFuture(_loadCache()).asyncExpand((_) {
      _booksController.add(_cache);
      return _booksController.stream.map((_) => _filterByUser(userId));
    });
  }

  @override
  Future<List<BookEntity>> getBooks(String userId, {ReadingStatus? status, String? search}) async {
    await _loadCache();
    var list = _filterByUser(userId);
    if (status != null) {
      list = list.where((b) => b.readingStatus == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final lower = search.toLowerCase();
      list = list.where((b) => b.title.toLowerCase().contains(lower) || b.author.toLowerCase().contains(lower)).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<BookEntity?> getBookById(String userId, String bookId) async {
    await _loadCache();
    try {
      return _cache.firstWhere((b) => b.id == bookId && b.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookEntity>> getFavoriteBooks(String userId) async {
    await _loadCache();
    return _cache.where((b) => b.userId == userId && b.isFavorite).toList();
  }

  Future<String> _saveCover(String userId, String bookId, Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final coversDir = Directory('${dir.path}/covers');
    if (!await coversDir.exists()) await coversDir.create(recursive: true);
    final file = File('${coversDir.path}/${userId}_$bookId.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Future<BookEntity> addBook(BookEntity book, {List<int>? coverImageBytes}) async {
    await _loadCache();
    String? coverUrl = book.coverUrl;
    if (coverImageBytes != null && coverImageBytes.isNotEmpty) {
      coverUrl = await _saveCover(book.userId, book.id, Uint8List.fromList(coverImageBytes));
    }
    final entity = BookEntity(
      id: book.id,
      userId: book.userId,
      title: book.title,
      author: book.author,
      genre: book.genre,
      description: book.description,
      totalPages: book.totalPages,
      coverUrl: coverUrl ?? book.coverUrl,
      readingStatus: book.readingStatus,
      startDate: book.startDate,
      finishDate: book.finishDate,
      rating: book.rating,
      notes: book.notes,
      currentPage: book.currentPage,
      isFavorite: book.isFavorite,
      bookNotes: book.bookNotes,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
    );
    _cache.add(BookModel.fromEntity(entity));
    await _persist();
    return entity;
  }

  @override
  Future<BookEntity> updateBook(BookEntity book, {List<int>? coverImageBytes}) async {
    await _loadCache();
    String? coverUrl = book.coverUrl;
    if (coverImageBytes != null && coverImageBytes.isNotEmpty) {
      coverUrl = await _saveCover(book.userId, book.id, Uint8List.fromList(coverImageBytes));
    }
    final entity = BookEntity(
      id: book.id,
      userId: book.userId,
      title: book.title,
      author: book.author,
      genre: book.genre,
      description: book.description,
      totalPages: book.totalPages,
      coverUrl: coverUrl ?? book.coverUrl,
      readingStatus: book.readingStatus,
      startDate: book.startDate,
      finishDate: book.finishDate,
      rating: book.rating,
      notes: book.notes,
      currentPage: book.currentPage,
      isFavorite: book.isFavorite,
      bookNotes: book.bookNotes,
      createdAt: book.createdAt,
      updatedAt: DateTime.now(),
    );
    final idx = _cache.indexWhere((b) => b.id == book.id);
    if (idx >= 0) _cache[idx] = BookModel.fromEntity(entity);
    await _persist();
    return entity;
  }

  @override
  Future<void> deleteBook(String userId, String bookId) async {
    await _loadCache();
    _cache.removeWhere((b) => b.id == bookId && b.userId == userId);
    await _persist();
  }

  @override
  Future<BookEntity> updateProgress(String userId, String bookId, int currentPage) async {
    await _loadCache();
    final idx = _cache.indexWhere((b) => b.id == bookId && b.userId == userId);
    if (idx < 0) throw const ServerFailure('Book not found');
    final b = _cache[idx];
    _cache[idx] = BookModel(
      id: b.id,
      userId: b.userId,
      title: b.title,
      author: b.author,
      genre: b.genre,
      description: b.description,
      totalPages: b.totalPages,
      coverUrl: b.coverUrl,
      readingStatus: b.readingStatus,
      startDate: b.startDate,
      finishDate: b.finishDate,
      rating: b.rating,
      notes: b.notes,
      currentPage: currentPage,
      isFavorite: b.isFavorite,
      bookNotes: b.bookNotes,
      createdAt: b.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return _cache[idx];
  }

  @override
  Future<BookEntity> toggleFavorite(String userId, String bookId) async {
    await _loadCache();
    final idx = _cache.indexWhere((b) => b.id == bookId && b.userId == userId);
    if (idx < 0) throw const ServerFailure('Book not found');
    final b = _cache[idx];
    _cache[idx] = BookModel(
      id: b.id,
      userId: b.userId,
      title: b.title,
      author: b.author,
      genre: b.genre,
      description: b.description,
      totalPages: b.totalPages,
      coverUrl: b.coverUrl,
      readingStatus: b.readingStatus,
      startDate: b.startDate,
      finishDate: b.finishDate,
      rating: b.rating,
      notes: b.notes,
      currentPage: b.currentPage,
      isFavorite: !b.isFavorite,
      bookNotes: b.bookNotes,
      createdAt: b.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return _cache[idx];
  }

  @override
  Future<BookEntity> addOrUpdateNote(String userId, String bookId, String noteId, String content, {String noteType = 'general'}) async {
    await _loadCache();
    final idx = _cache.indexWhere((b) => b.id == bookId && b.userId == userId);
    if (idx < 0) throw const ServerFailure('Book not found');
    final b = _cache[idx];
    final now = DateTime.now();
    final existingNotes = b.bookNotes.map((n) => BookNoteModel.fromEntity(n).toFirestore()).toList();
    final existing = existingNotes.cast<Map<String, dynamic>>().where((e) => e['id'] == noteId).toList();
    final createdAt = existing.isNotEmpty && existing.first['createdAt'] != null
        ? existing.first['createdAt'].toString()
        : now.toIso8601String();
    final noteMap = {
      'id': noteId,
      'bookId': bookId,
      'content': content,
      'noteType': noteType,
      'createdAt': createdAt,
      'updatedAt': now.toIso8601String(),
    };
    final noteIdx = existingNotes.indexWhere((e) => (e as Map)['id'] == noteId);
    if (noteIdx >= 0) {
      existingNotes[noteIdx] = noteMap;
    } else {
      existingNotes.add(noteMap);
    }
    final newNotes = existingNotes.map((e) => BookNoteModel.fromFirestore(Map<String, dynamic>.from(e), e['id'] as String? ?? '')).toList();
    _cache[idx] = BookModel(
      id: b.id,
      userId: b.userId,
      title: b.title,
      author: b.author,
      genre: b.genre,
      description: b.description,
      totalPages: b.totalPages,
      coverUrl: b.coverUrl,
      readingStatus: b.readingStatus,
      startDate: b.startDate,
      finishDate: b.finishDate,
      rating: b.rating,
      notes: b.notes,
      currentPage: b.currentPage,
      isFavorite: b.isFavorite,
      bookNotes: newNotes,
      createdAt: b.createdAt,
      updatedAt: now,
    );
    await _persist();
    return _cache[idx];
  }

  @override
  Future<BookEntity> deleteNote(String userId, String bookId, String noteId) async {
    await _loadCache();
    final idx = _cache.indexWhere((b) => b.id == bookId && b.userId == userId);
    if (idx < 0) throw const ServerFailure('Book not found');
    final b = _cache[idx];
    final newNotes = b.bookNotes.where((n) => n.id != noteId).map((n) => BookNoteModel.fromEntity(n)).toList();
    _cache[idx] = BookModel(
      id: b.id,
      userId: b.userId,
      title: b.title,
      author: b.author,
      genre: b.genre,
      description: b.description,
      totalPages: b.totalPages,
      coverUrl: b.coverUrl,
      readingStatus: b.readingStatus,
      startDate: b.startDate,
      finishDate: b.finishDate,
      rating: b.rating,
      notes: b.notes,
      currentPage: b.currentPage,
      isFavorite: b.isFavorite,
      bookNotes: newNotes,
      createdAt: b.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return _cache[idx];
  }
}
