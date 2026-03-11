import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tracker/features/books/presentation/pages/add_book_page.dart';
import 'package:tracker/features/books/presentation/pages/book_detail_page.dart';
import 'package:tracker/main_shell.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  static const String home = '/';
  static const String library = '/library';
  static const String statistics = '/statistics';
  static const String addBook = '/add-book';
  static const String bookDetail = '/book/:id';

  static String bookDetailPath(String id) => '/book/$id';

  GoRouter get router {
    return GoRouter(
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
      initialLocation: home,
      routes: [
        GoRoute(
          path: home,
          builder: (_, state) => MainShell(location: state.matchedLocation),
        ),
        GoRoute(
          path: library,
          builder: (_, state) => MainShell(location: state.matchedLocation),
        ),
        GoRoute(
          path: statistics,
          builder: (_, state) => MainShell(location: state.matchedLocation),
        ),
        GoRoute(
          path: addBook,
          builder: (_, __) => const AddBookPage(),
        ),
        GoRoute(
          path: '/book/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BookDetailPage(bookId: id);
          },
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
