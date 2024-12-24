import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/book.dart';
import '../models/reader_settings.dart';
import '../providers/reader_state.dart';
import 'reader_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  late Box<Book> booksBox;
  late Box<ReaderSettings> settingsBox;
  ReaderState? readerState;

  @override
  void initState() {
    super.initState();
    booksBox = Hive.box('books');
    settingsBox = Hive.box('settings');
  }

  void _openBook(Book book) {
    readerState?.dispose();
    readerState = ReaderState(
      book: book,
      settingsBox: settingsBox,
    )..loadBook();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: readerState!,
          child: const ReaderView(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    readerState?.dispose();
    super.dispose();
  }

  Future<void> _importBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      final book = Book(
        title: fileName,
        filePath: file.path,
        lastReadPosition: 0,
      );

      await booksBox.add(book);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的书架'),
      ),
      body: ValueListenableBuilder(
        valueListenable: booksBox.listenable(),
        builder: (context, Box<Book> box, _) {
          final books = box.values.toList();
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () => _openBook(book),
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importBook,
        child: const Icon(Icons.add),
      ),
    );
  }
}
