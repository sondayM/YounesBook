import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Reading Statistics', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _StatRow(title: 'Total books read', value: '${stats.booksRead}'),
              _StatRow(title: 'Total pages read', value: '${stats.totalPages}'),
              _StatRow(title: 'Average rating', value: stats.avgRating?.toStringAsFixed(1) ?? '—'),
              _StatRow(title: 'Books read this year', value: '${stats.booksThisYear}'),
              _StatRow(title: 'Books read this month', value: '${stats.booksThisMonth}'),
              const SizedBox(height: 24),
              if (stats.pagesPerMonth.isNotEmpty) ...[
                Text('Pages per month', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (stats.pagesPerMonth.values.isEmpty ? 1 : stats.pagesPerMonth.values.reduce((a, b) => a > b ? a : b) * 1.2),
                      barGroups: stats.pagesPerMonth.entries.toList().asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value.toDouble(),
                              color: Theme.of(context).colorScheme.primary,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text('${v.toInt()}'))),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final list = stats.pagesPerMonth.keys.toList();
                              final i = v.toInt();
                              if (i >= 0 && i < list.length) return Text(list[i], style: const TextStyle(fontSize: 10));
                              return const Text('');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (stats.byGenre.isNotEmpty) ...[
                Text('Books by genre', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      sections: stats.byGenre.entries.map((e) => PieChartSectionData(
                        value: e.value.toDouble(),
                        title: '${e.key}\n${e.value}',
                        color: _colorForGenre(e.key),
                        radius: 60,
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Color _colorForGenre(String genre) {
    final hash = genre.hashCode.abs();
    return Color(0xFF3E7CB1 + (hash % 0xFFFFFF) % 0x800000);
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
  const _StatRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
