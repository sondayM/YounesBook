import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/book_cover_image.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';
import 'package:tracker/features/books/presentation/bloc/books_bloc.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  ReadingStatus? _filter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Library',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title or author...',
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.cardDark
                          : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onChanged: (_) => context.read<BooksBloc>().add(BooksLoadRequested(
                          statusFilter: _filter,
                          search: _searchController.text.isEmpty ? null : _searchController.text,
                        )),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(label: 'All', selected: _filter == null, onTap: _filterAll),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: ReadingStatus.wantToRead.displayName,
                          selected: _filter == ReadingStatus.wantToRead,
                          onTap: () => _setFilter(ReadingStatus.wantToRead),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: ReadingStatus.currentlyReading.displayName,
                          selected: _filter == ReadingStatus.currentlyReading,
                          onTap: () => _setFilter(ReadingStatus.currentlyReading),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: ReadingStatus.finished.displayName,
                          selected: _filter == ReadingStatus.finished,
                          onTap: () => _setFilter(ReadingStatus.finished),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocConsumer<BooksBloc, BooksState>(
            listener: (context, state) {
              if (state.status == BooksStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message ?? 'Error'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            buildWhen: (prev, curr) => prev.books != curr.books || prev.status != curr.status,
            builder: (context, state) {
              if (state.status == BooksStatus.initial) {
                context.read<BooksBloc>().add(BooksLoadRequested(statusFilter: _filter, search: _searchController.text.isEmpty ? null : _searchController.text));
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (state.status == BooksStatus.loading && state.books.isEmpty) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              final books = state.books;
              if (books.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No books yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BookGridCard(book: books[index]),
                    childCount: books.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _filterAll() {
    setState(() => _filter = null);
    context.read<BooksBloc>().add(const BooksLoadRequested());
  }

  void _setFilter(ReadingStatus status) {
    setState(() => _filter = status);
    context.read<BooksBloc>().add(BooksLoadRequested(
          statusFilter: status,
          search: _searchController.text.isEmpty ? null : _searchController.text,
        ));
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookGridCard extends StatelessWidget {
  const _BookGridCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BookCoverImage(
                      coverUrl: book.coverUrl,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (book.totalPages > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: book.progressPercentage,
                              backgroundColor: Colors.white.withOpacity(0.4),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}
