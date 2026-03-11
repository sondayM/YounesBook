import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tracker/core/errors/failures.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';
import 'package:tracker/features/books/domain/repositories/books_repository.dart';

part 'books_event.dart';
part 'books_state.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc({required BooksRepository booksRepository, required String userId})
      : _booksRepository = booksRepository,
        _userId = userId,
        super(const BooksState.initial()) {
    on<BooksWatchRequested>(_onWatch);
    on<BooksLoadRequested>(_onLoad);
    on<BooksAddRequested>(_onAdd);
    on<BooksUpdateRequested>(_onUpdate);
    on<BooksDeleteRequested>(_onDelete);
    on<BooksUpdateProgressRequested>(_onUpdateProgress);
    on<BooksToggleFavoriteRequested>(_onToggleFavorite);
    on<BooksAddNoteRequested>(_onAddNote);
    on<BooksUpdateNoteRequested>(_onUpdateNote);
    on<BooksDeleteNoteRequested>(_onDeleteNote);
    add(const BooksWatchRequested());
  }

  final BooksRepository _booksRepository;
  final String _userId;

  void _onWatch(BooksWatchRequested event, Emitter<BooksState> emit) async {
    await emit.forEach<List<BookEntity>>(
      _booksRepository.watchBooks(_userId),
      onData: (books) => BooksState.loaded(books),
      onError: (e, _) => BooksState.failure(e is Failure ? e.message ?? 'Error' : e.toString()),
    );
  }

  Future<void> _onLoad(BooksLoadRequested event, Emitter<BooksState> emit) async {
    if (state.status != BooksStatus.loaded) emit(const BooksState.loading());
    try {
      final books = await _booksRepository.getBooks(
        _userId,
        status: event.statusFilter,
        search: event.search,
      );
      emit(BooksState.loaded(books));
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to load books'));
    }
  }

  Future<void> _onAdd(BooksAddRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.addBook(event.book, coverImageBytes: event.coverImageBytes);
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to add book'));
    }
  }

  Future<void> _onUpdate(BooksUpdateRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.updateBook(event.book, coverImageBytes: event.coverImageBytes);
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to update book'));
    }
  }

  Future<void> _onDelete(BooksDeleteRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.deleteBook(_userId, event.bookId);
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to delete book'));
    }
  }

  Future<void> _onUpdateProgress(BooksUpdateProgressRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.updateProgress(_userId, event.bookId, event.currentPage);
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to update progress'));
    }
  }

  Future<void> _onToggleFavorite(BooksToggleFavoriteRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.toggleFavorite(_userId, event.bookId);
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to update favorite'));
    }
  }

  Future<void> _onAddNote(BooksAddNoteRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.addOrUpdateNote(
        _userId,
        event.bookId,
        event.noteId,
        event.content,
        noteType: event.noteType,
      );
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to add note'));
    }
  }

  Future<void> _onUpdateNote(BooksUpdateNoteRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.addOrUpdateNote(
        _userId,
        event.bookId,
        event.noteId,
        event.content,
        noteType: event.noteType,
      );
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to update note'));
    }
  }

  Future<void> _onDeleteNote(BooksDeleteNoteRequested event, Emitter<BooksState> emit) async {
    try {
      await _booksRepository.deleteNote(_userId, event.bookId, event.noteId);
      add(const BooksWatchRequested());
    } on Failure catch (f) {
      emit(BooksState.failure(f.message ?? 'Failed to delete note'));
    }
  }
}
