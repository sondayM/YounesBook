import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
import 'package:tracker/core/utils/date_utils.dart';
import 'package:tracker/core/widgets/book_cover_image.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';
import 'package:tracker/features/books/presentation/bloc/books_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BooksBloc, BooksState>(
        builder: (context, state) {
          final books = state.books;
          if (state.status == BooksStatus.initial || state.status == BooksStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = _computeStats(books);
          final currentReading = books.where((b) => b.readingStatus == ReadingStatus.currentlyReading).toList();
          final favorites = books.where((b) => b.isFavorite).toList();
          final recentlyAdded = books.take(5).toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      _StatsGrid(stats: stats),
                      if (currentReading.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Currently Reading', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _CurrentReadingCard(book: currentReading.first),
                      ],
                      if (favorites.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Favorites', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: favorites.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _FavoriteCard(book: favorites[index]),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text('Recently Added', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (recentlyAdded.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Add your first book to get started!')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = recentlyAdded[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _BookListTile(book: book),
                        );
                      },
                      childCount: recentlyAdded.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  _HomeStats _computeStats(List<BookEntity> books) {
    final now = DateTime.now();
    final finished = books.where((b) => b.readingStatus == ReadingStatus.finished).toList();
    final reading = books.where((b) => b.readingStatus == ReadingStatus.currentlyReading).toList();
    final toRead = books.where((b) => b.readingStatus == ReadingStatus.wantToRead).toList();
    final pagesThisMonth = finished
        .where((b) => b.finishDate != null && AppDateUtils.isSameMonth(b.finishDate!, now))
        .fold<int>(0, (sum, b) => sum + (b.totalPages));
    return _HomeStats(
      booksRead: finished.length,
      booksReading: reading.length,
      booksToRead: toRead.length,
      pagesThisMonth: pagesThisMonth,
    );
  }
}

class _HomeStats {
  _HomeStats({
    required this.booksRead,
    required this.booksReading,
    required this.booksToRead,
    required this.pagesThisMonth,
  });
  final int booksRead;
  final int booksReading;
  final int booksToRead;
  final int pagesThisMonth;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final _HomeStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          title: 'Books Read',
          value: '${stats.booksRead}',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Reading',
          value: '${stats.booksReading}',
          icon: Icons.menu_book_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        _StatCard(
          title: 'To Read',
          value: '${stats.booksToRead}',
          icon: Icons.bookmark_border,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Pages This Month',
          value: '${stats.pagesThisMonth}',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentReadingCard extends StatelessWidget {
  const _CurrentReadingCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BookCoverImage(coverUrl: book.coverUrl, width: 56, height: 84),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(book.author, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: book.progressPercentage),
                    const SizedBox(height: 4),
                    Text('${(book.progressPercentage * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookListTile extends StatelessWidget {
  const _BookListTile({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BookCoverImage(coverUrl: book.coverUrl, width: 44, height: 66),
        ),
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(book.author),
        trailing: book.rating != null ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 18, color: Colors.amber.shade700),
            const SizedBox(width: 4),
            Text('${book.rating}'),
          ],
        ) : null,
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        child: SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: BookCoverImage(
                  coverUrl: book.coverUrl,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
