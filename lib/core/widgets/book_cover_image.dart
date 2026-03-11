import 'dart:io';
import 'package:flutter/material.dart';

/// Shows a book cover from either a network URL or a local file path.
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    this.coverUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  final String? coverUrl;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return _placeholder(context);
    }
    if (coverUrl!.startsWith('http://') || coverUrl!.startsWith('https://')) {
      return Image.network(coverUrl!, width: width, height: height, fit: fit);
    }
    final file = File(coverUrl!);
    if (file.existsSync()) {
      return Image.file(file, width: width, height: height, fit: fit);
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.menu_book, size: 48),
    );
  }
}
