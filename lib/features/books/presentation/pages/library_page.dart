import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                    onChanged: (_) => context.read<BooksBloc>().add(BooksLoadRequested(
                          statusFilter: _filter,
                          search: _searchController.text.isEmpty ? null : _searchController.text,
                        )),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _filter == null,
                          onTap: () {
                            setState(() => _filter = null);
                            context.read<BooksBloc>().add(const BooksLoadRequested());
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: ReadingStatus.wantToRead.displayName,
                          selected: _filter == ReadingStatus.wantToRead,
                          onTap: () {
                            setState(() => _filter = ReadingStatus.wantToRead);
                            context.read<BooksBloc>().add(BooksLoadRequested(statusFilter: ReadingStatus.wantToRead, search: _searchController.text.isEmpty ? null : _searchController.text));
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: ReadingStatus.currentlyReading.displayName,
                          selected: _filter == ReadingStatus.currentlyReading,
                          onTap: () {
                            setState(() => _filter = ReadingStatus.currentlyReading);
                            context.read<BooksBloc>().add(BooksLoadRequested(statusFilter: ReadingStatus.currentlyReading, search: _searchController.text.isEmpty ? null : _searchController.text));
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: ReadingStatus.finished.displayName,
                          selected: _filter == ReadingStatus.finished,
                          onTap: () {
                            setState(() => _filter = ReadingStatus.finished);
                            context.read<BooksBloc>().add(BooksLoadRequested(statusFilter: ReadingStatus.finished, search: _searchController.text.isEmpty ? null : _searchController.text));
                          },
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
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
                return const SliverFillRemaining(child: Center(child: Text('No books yet')));
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BookGridCard(book: books[index]),
                    childCount: books.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _BookGridCard extends StatelessWidget {
  const _BookGridCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRouter.bookDetailPath(book.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Expanded(
              child: BookCoverImage(
                coverUrl: book.coverUrl,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                  Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  if (book.totalPages > 0)
                    LinearProgressIndicator(value: book.progressPercentage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
