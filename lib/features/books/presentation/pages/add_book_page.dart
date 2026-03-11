import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tracker/features/books/domain/entities/book_entity.dart';
import 'package:tracker/features/books/domain/entities/reading_status.dart';
import 'package:tracker/features/books/presentation/bloc/books_bloc.dart';
import 'package:uuid/uuid.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _notesController = TextEditingController();
  ReadingStatus _status = ReadingStatus.wantToRead;
  int? _rating;
  DateTime? _startDate;
  DateTime? _finishDate;
  File? _coverFile;
  List<int>? _coverBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _totalPagesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (x != null) {
      setState(() {
        _coverFile = File(x.path);
        _coverBytes = null;
      });
      final bytes = await x.readAsBytes();
      setState(() => _coverBytes = bytes);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;
    final totalPages = int.tryParse(_totalPagesController.text) ?? 0;
    final book = BookEntity(
      id: const Uuid().v4(),
      userId: user.id,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _genreController.text.trim().isEmpty ? null : _genreController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      totalPages: totalPages,
      coverUrl: null,
      readingStatus: _status,
      startDate: _startDate,
      finishDate: _finishDate,
      rating: _rating,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      currentPage: 0,
      isFavorite: false,
      bookNotes: [],
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    context.read<BooksBloc>().add(BooksAddRequested(book: book, coverImageBytes: _coverBytes));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: BlocListener<BooksBloc, BooksState>(
        listener: (context, state) {
          if (state.status == BooksStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: _coverFile != null
                          ? Image.file(_coverFile!, fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey.shade600),
                                const SizedBox(height: 8),
                                Text('Tap to add cover', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _genreController,
                  decoration: const InputDecoration(labelText: 'Genre', prefixIcon: Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _totalPagesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Pages', prefixIcon: Icon(Icons.numbers)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v) == null || int.tryParse(v)! < 0) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReadingStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Reading Status'),
                  items: ReadingStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                          if (d != null) setState(() => _startDate = d);
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Start Date'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                          if (d != null) setState(() => _finishDate = d);
                        },
                        icon: const Icon(Icons.event),
                        label: Text(_finishDate != null ? '${_finishDate!.day}/${_finishDate!.month}/${_finishDate!.year}' : 'Finish Date'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Rating', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return IconButton(
                      icon: Icon(_rating != null && star <= _rating! ? Icons.star : Icons.star_border),
                      color: Colors.amber,
                      onPressed: () => setState(() => _rating = star),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes', alignLabelWithHint: true),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Add Book'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
