import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_novel_reader/models/book.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_novel_reader/models/reader_settings.dart';
import 'package:local_novel_reader/pages/reader_page.dart';

class BookShelfPage extends StatefulWidget {
  const BookShelfPage({super.key});

  @override
  State<BookShelfPage> createState() => _BookShelfPageState();
}

class _BookShelfPageState extends State<BookShelfPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Box<Book> box;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    box = Hive.box<Book>('books');
  }

  List<Book> get books {
    final bookList = box.values.toList()
      ..sort((a, b) {
        if (a.lastReadTime == null && b.lastReadTime == null) {
          return 0;
        }
        if (a.lastReadTime == null) return 1;
        if (b.lastReadTime == null) return -1;
        return b.lastReadTime!.compareTo(a.lastReadTime!);
      });
    return bookList;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的书架'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => importBook(),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          var lastRead = '暂未阅读';

          if (book.lastReadTime != null) {
            lastRead =
                '上次阅读：${DateFormat('yyyy-MM-dd HH:mm').format(book.lastReadTime!)}';
          }

          return ListTile(
            onTap: () => _openBook(context, book),
            onLongPress: () => _deleteBook(context, book),
            leading: Icon(
              Icons.book,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              book.title,
              style: TextTheme.of(context).bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              lastRead,
              style: TextTheme.of(context).labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }

  void _openBook(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListenableBuilder(
          listenable: Listenable.merge(
            [
              Hive.box<Book>('books').listenable(),
              Hive.box<ReaderSettings>('settings').listenable(),
            ],
          ),
          builder: (context, _) => ReaderPage(
            key: UniqueKey(),
            book: book,
          ),
        ),
      ),
    );
  }

  Future<void> importBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String content = await file.readAsString();

      final book = Book(
        title: fileName,
        content: content,
      );

      await box.add(book);
    }
  }

  Future<void> _deleteBook(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除书籍'),
        content: Text('确定要删除《${book.title}》吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await book.delete();
    }
  }
}
