import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
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
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Track your reading journey',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _StatsGrid(stats: stats),
                      if (currentReading.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionTitle(title: 'Currently Reading'),
                        const SizedBox(height: 12),
                        _CurrentReadingCard(book: currentReading.first),
                      ],
                      if (favorites.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionTitle(title: 'Favorites'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 132,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: favorites.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(right: index < favorites.length - 1 ? 14 : 0),
                              child: _FavoriteCard(book: favorites[index]),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      _SectionTitle(title: 'Recently Added'),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (recentlyAdded.isEmpty)
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Add your first book to get started',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BookListTile(book: recentlyAdded[index]),
                      ),
                      childCount: recentlyAdded.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final _HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _StatCard(
          title: 'Books Read',
          value: '${stats.booksRead}',
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          bgColor: isDark ? AppColors.success.withOpacity(0.15) : AppColors.successLight,
        ),
        _StatCard(
          title: 'Reading',
          value: '${stats.booksReading}',
          icon: Icons.menu_book_rounded,
          color: AppColors.primary,
          bgColor: isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primary.withOpacity(0.08),
        ),
        _StatCard(
          title: 'To Read',
          value: '${stats.booksToRead}',
          icon: Icons.bookmark_rounded,
          color: AppColors.warning,
          bgColor: isDark ? AppColors.warning.withOpacity(0.15) : AppColors.warningLight,
        ),
        _StatCard(
          title: 'Pages This Month',
          value: '${stats.pagesThisMonth}',
          icon: Icons.trending_up_rounded,
          color: AppColors.info,
          bgColor: isDark ? AppColors.info.withOpacity(0.15) : AppColors.infoLight,
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
    required this.bgColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentReadingCard extends StatelessWidget {
  const _CurrentReadingCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BookCoverImage(coverUrl: book.coverUrl, width: 64, height: 96),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: book.progressPercentage,
                        minHeight: 6,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(book.progressPercentage * 100).round()}% complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BookCoverImage(coverUrl: book.coverUrl, width: 48, height: 72),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (book.rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '${book.rating}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 96,
          height: 132,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BookCoverImage(
                    coverUrl: book.coverUrl,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  book.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
