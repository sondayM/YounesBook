import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/router/app_router.dart';
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
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: BookCoverImage(coverUrl: currentBook.coverUrl, width: 150, height: 220),
                  ),
                ),
                const SizedBox(height: 16),
                Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
                Text(book.author, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                if (book.genre != null) Text(book.genre!, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                if (book.totalPages > 0) ...[
                  Text('Progress: ${book.currentPage} / ${book.totalPages}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: book.progressPercentage),
                  Text('${(book.progressPercentage * 100).round()}%'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _updateProgress(context, currentBook),
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Progress'),
                  ),
                ],
                const SizedBox(height: 12),
                if (book.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${book.rating}/5'),
                    ],
                  ),
                if (book.startDate != null) Text('Started: ${AppDateUtils.formatDate(book.startDate)}'),
                if (book.finishDate != null) Text('Finished: ${AppDateUtils.formatDate(book.finishDate)}'),
                if (book.description != null && book.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(book.description!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (book.notes != null && book.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                  Text(book.notes!),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Favorites', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(book.isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: Colors.red,
                      onPressed: () => context.read<BooksBloc>().add(BooksToggleFavoriteRequested(bookId)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Book Notes', style: Theme.of(context).textTheme.titleMedium),
                ...book.bookNotes.map((n) => _NoteTile(note: n, bookId: bookId)),
                OutlinedButton.icon(
                  onPressed: () => _addNote(context, bookId),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Note'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEdit(BuildContext context) {
    context.push(AppRouter.addBook); // TODO: pass book for edit - could use extra or a separate edit route
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<BooksBloc>().add(BooksDeleteRequested(bookId));
              Navigator.pop(ctx);
              context.pop();
            },
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

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.bookId});

  final BookNoteEntity note;
  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(note.content),
        subtitle: Text(AppDateUtils.formatDateTime(note.createdAt)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            context.read<BooksBloc>().add(BooksDeleteNoteRequested(bookId: bookId, noteId: note.id));
          },
        ),
      ),
    );
  }
}
