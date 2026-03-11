import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/date_utils.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';
import 'package:tracker/features/books/presentation/bloc/books_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BooksBloc, BooksState>(
        builder: (context, state) {
          if (state.status == BooksStatus.initial || state.status == BooksStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = state.books;
          final stats = _computeStats(books);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your reading at a glance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _StatRow(title: 'Total books read', value: '${stats.booksRead}', icon: Icons.check_circle_rounded),
                      const SizedBox(height: 10),
                      _StatRow(title: 'Total pages read', value: '${stats.totalPages}', icon: Icons.auto_stories_rounded),
                      const SizedBox(height: 10),
                      _StatRow(title: 'Average rating', value: stats.avgRating?.toStringAsFixed(1) ?? '—', icon: Icons.star_rounded),
                      const SizedBox(height: 10),
                      _StatRow(title: 'Books this year', value: '${stats.booksThisYear}', icon: Icons.calendar_today_rounded),
                      const SizedBox(height: 10),
                      _StatRow(title: 'Books this month', value: '${stats.booksThisMonth}', icon: Icons.trending_up_rounded),
                      const SizedBox(height: 28),
                      if (stats.pagesPerMonth.isNotEmpty) ...[
                        Text(
                          'Pages per month',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (stats.pagesPerMonth.values.isEmpty ? 1 : stats.pagesPerMonth.values.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(),
                                barGroups: stats.pagesPerMonth.entries.toList().asMap().entries.map((e) {
                                  return BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.value.toDouble(),
                                        color: AppColors.primary,
                                        width: 20,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                      ),
                                    ],
                                    showingTooltipIndicators: [0],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (v, _) => Text(
                                        '${v.toInt()}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, _) {
                                        final list = stats.pagesPerMonth.keys.toList();
                                        final i = v.toInt();
                                        if (i >= 0 && i < list.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              list[i],
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                                    strokeWidth: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (stats.byGenre.isNotEmpty) ...[
                        Text(
                          'Books by genre',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                sections: stats.byGenre.entries.map((e) => PieChartSectionData(
                                  value: e.value.toDouble(),
                                  title: '${e.key}\n${e.value}',
                                  color: _colorForGenre(e.key),
                                  radius: 48,
                                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                )).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _colorForGenre(String genre) {
    final hash = genre.hashCode.abs();
    final hues = [0xFF3E7CB1, 0xFF22C55E, 0xFFF59E0B, 0xFF8B5CF6, 0xFFEC4899];
    return Color(hues[hash % hues.length]);
  }

  _Stats _computeStats(List<BookEntity> books) {
    final now = DateTime.now();
    final finished = books.where((b) => b.readingStatus == ReadingStatus.finished).toList();
    final totalPages = finished.fold<int>(0, (sum, b) => sum + b.totalPages);
    double? avgRating;
    if (finished.any((b) => b.rating != null)) {
      final withRating = finished.where((b) => b.rating != null).toList();
      avgRating = withRating.fold<int>(0, (s, b) => s + (b.rating ?? 0)) / withRating.length;
    }
    final booksThisYear = finished.where((b) => b.finishDate != null && AppDateUtils.isSameYear(b.finishDate!, now)).length;
    final booksThisMonth = finished.where((b) => b.finishDate != null && AppDateUtils.isSameMonth(b.finishDate!, now)).length;
    final Map<String, int> byGenre = {};
    for (final b in books) {
      final g = b.genre ?? 'Other';
      byGenre[g] = (byGenre[g] ?? 0) + 1;
    }
    final Map<String, int> pagesPerMonth = {};
    for (final b in finished) {
      if (b.finishDate == null) continue;
      final key = '${b.finishDate!.year}-${b.finishDate!.month}';
      pagesPerMonth[key] = (pagesPerMonth[key] ?? 0) + b.totalPages;
    }
    final sorted = pagesPerMonth.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final last6 = sorted.length > 6 ? sorted.sublist(sorted.length - 6) : sorted;
    final pagesPerMonthLast = Map.fromEntries(last6);
    return _Stats(
      booksRead: finished.length,
      totalPages: totalPages,
      avgRating: avgRating,
      booksThisYear: booksThisYear,
      booksThisMonth: booksThisMonth,
      byGenre: byGenre,
      pagesPerMonth: pagesPerMonthLast,
    );
  }
}

class _Stats {
  _Stats({
    required this.booksRead,
    required this.totalPages,
    this.avgRating,
    required this.booksThisYear,
    required this.booksThisMonth,
    required this.byGenre,
    required this.pagesPerMonth,
  });
  final int booksRead;
  final int totalPages;
  final double? avgRating;
  final int booksThisYear;
  final int booksThisMonth;
  final Map<String, int> byGenre;
  final Map<String, int> pagesPerMonth;
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
