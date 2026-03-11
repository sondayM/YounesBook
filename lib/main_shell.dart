import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/features/books/presentation/pages/library_page.dart';
import 'package:tracker/features/home/presentation/pages/home_page.dart';
import 'package:tracker/features/statistics/presentation/pages/statistics_page.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.location});

  final String location;

  int get _currentIndex {
    switch (location) {
      case AppRouter.library:
        return 1;
      case AppRouter.statistics:
        return 2;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.library);
        break;
      case 2:
        context.go(AppRouter.statistics);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          LibraryPage(),
          StatisticsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => _onTap(context, index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: 'Statistics',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addBook),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
