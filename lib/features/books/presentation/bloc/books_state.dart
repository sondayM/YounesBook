part of 'books_bloc.dart';

enum BooksStatus { initial, loading, loaded, failure }

class BooksState extends Equatable {
  const BooksState._({this.status = BooksStatus.initial, this.books = const [], this.message});

  const BooksState.initial() : this._();
  const BooksState.loading() : this._(status: BooksStatus.loading);
  const BooksState.loaded(List<BookEntity> b) : this._(status: BooksStatus.loaded, books: b);
  const BooksState.failure(String m) : this._(status: BooksStatus.failure, message: m);

  final BooksStatus status;
  final List<BookEntity> books;
  final String? message;

  @override
  List<Object?> get props => [status, books, message];
}
