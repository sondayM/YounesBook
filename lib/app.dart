import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/router/app_router.dart';
import 'package:tracker/core/theme/app_theme.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tracker/features/books/domain/repositories/books_repository.dart';
import 'package:tracker/features/books/presentation/bloc/books_bloc.dart';

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({
    super.key,
    required this.authBloc,
    required this.authRepository,
    required this.booksRepository,
    required this.appRouter,
  });

  final AuthBloc authBloc;
  final AuthRepository authRepository;
  final BooksRepository booksRepository;
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (prev, curr) => prev.status != curr.status || prev.user?.id != curr.user?.id,
        builder: (context, state) {
          final isAuthenticated = state.status == AuthStatus.authenticated && state.user != null;
          final app = MaterialApp.router(
            title: 'Book Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: appRouter.router,
          );
          if (isAuthenticated && state.user != null) {
            return BlocProvider<BooksBloc>(
              create: (_) => BooksBloc(
                booksRepository: booksRepository,
                userId: state.user!.id,
              ),
              child: app,
            );
          }
          return app;
        },
      ),
    );
  }
}
