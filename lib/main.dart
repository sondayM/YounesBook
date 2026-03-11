import 'package:flutter/material.dart';
import 'package:tracker/app.dart';
import 'package:tracker/core/router/app_router.dart';
import 'package:tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tracker/features/books/data/repositories/books_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepository = AuthRepositoryImpl();
  await authRepository.ensureDefaultUser();
  final booksRepository = BooksRepositoryImpl();
  final authBloc = AuthBloc(authRepository: authRepository);
  authBloc.add(const AuthCheckRequested());
  final appRouter = AppRouter(authBloc);
  runApp(BookTrackerApp(
    authBloc: authBloc,
    authRepository: authRepository,
    booksRepository: booksRepository,
    appRouter: appRouter,
  ));
}
