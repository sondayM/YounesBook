import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/date_utils.dart';
import 'package:tracker/core/widgets/book_cover_image.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/book_note_entity.dart';
import 'package:tracker/features/books/presentation/bloc/books_bloc.dart';

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _openEdit(context)),
          IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _confirmDelete(context)),
        ],
      ),
      body: BlocBuilder<BooksBloc, BooksState>(
        buildWhen: (prev, curr) => prev.books != curr.books,
        builder: (context, state) {
          BookEntity? book;
          for (final b in state.books) {
            if (b.id == bookId) { book = b; break; }
          }
          if (book == null) {
            if (state.books.isEmpty) return const Center(child: CircularProgressIndicator());
            return const Center(child: Text('Book not found'));
          }
          final currentBook = book;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BookCoverImage(coverUrl: currentBook.coverUrl, width: 160, height: 240),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  currentBook.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  currentBook.author,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (currentBook.genre != null && currentBook.genre!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentBook.genre!,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (currentBook.totalPages > 0) ...[
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              '${currentBook.currentPage} / ${currentBook.totalPages}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: currentBook.progressPercentage,
                            minHeight: 10,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _updateProgress(context, currentBook),
                            icon: const Icon(Icons.edit_rounded, size: 20),
                            label: const Text('Update Progress'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (currentBook.rating != null) ...[
                  _SectionCard(
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '${currentBook.rating} / 5',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (currentBook.startDate != null || currentBook.finishDate != null)
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentBook.startDate != null)
                          _DetailRow(label: 'Started', value: AppDateUtils.formatDate(currentBook.startDate)),
                        if (currentBook.finishDate != null) ...[
                          if (currentBook.startDate != null) const SizedBox(height: 8),
                          _DetailRow(label: 'Finished', value: AppDateUtils.formatDate(currentBook.finishDate)),
                        ],
                      ],
                    ),
                  ),
                if (currentBook.description != null && currentBook.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          currentBook.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
                if (currentBook.notes != null && currentBook.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(currentBook.notes!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _SectionCard(
                  child: Row(
                    children: [
                      Text('Favorite', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton.filled(
                        onPressed: () => context.read<BooksBloc>().add(BooksToggleFavoriteRequested(bookId)),
                        icon: Icon(currentBook.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: currentBook.isFavorite ? Colors.red.shade50 : null,
                          foregroundColor: currentBook.isFavorite ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Book Notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () => _addNote(context, bookId),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...currentBook.bookNotes.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NoteTile(note: n, bookId: bookId),
                )),
                if (currentBook.bookNotes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No notes yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEdit(BuildContext context) => context.push(AppRouter.addBook);

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<BooksBloc>().add(BooksDeleteRequested(bookId));
              Navigator.pop(ctx);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateProgress(BuildContext context, BookEntity book) {
    final controller = TextEditingController(text: '${book.currentPage}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Progress'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Current Page',
            hintText: 'Max ${book.totalPages}',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 0 && page <= book.totalPages) {
                context.read<BooksBloc>().add(BooksUpdateProgressRequested(bookId: bookId, currentPage: page));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addNote(BuildContext context, String bookId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Quote, thought, or summary...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final content = controller.text.trim();
              if (content.isNotEmpty) {
                context.read<BooksBloc>().add(BooksAddNoteRequested(
                      bookId: bookId,
                      noteId: '${DateTime.now().millisecondsSinceEpoch}',
                      content: content,
                    ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65))),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.bookId});

  final BookNoteEntity note;
  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.content, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  AppDateUtils.formatDateTime(note.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => context.read<BooksBloc>().add(BooksDeleteNoteRequested(bookId: bookId, noteId: note.id)),
          ),
        ],
      ),
    );
  }
}
