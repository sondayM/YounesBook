import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.addBook),
        tooltip: 'Add Book',
        child: const Icon(Icons.add),
      ),
    );
  }
}
