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

  @override
  void initState() {
    super.initState();
    booksBox = Hive.box('books');
    settingsBox = Hive.box('settings');
  }

  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ReaderState(book: book, settingsBox: settingsBox),
          child: ReaderPage(book: book),
        ),
      ),
    );
  }

  Future<void> _importBook() async {
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

      await booksBox.add(book);
      setState(() {});
    }
  }

  Future<void> _deleteBook(Book book) async {
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
          final books = box.values.toList()
            ..sort((a, b) {
              // 如果两本书都没有阅读时间，按添加顺序排序
              if (a.lastReadTime == null && b.lastReadTime == null) {
                return 0;
              }
              // 没有阅读时间的书排在后面
              if (a.lastReadTime == null) return 1;
              if (b.lastReadTime == null) return -1;

              // 按时间倒序排序
              return b.lastReadTime!.compareTo(a.lastReadTime!);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              var lastRead = '暂未阅读';
              if (book.lastReadChapterIndex != null &&
                  book.lastReadPosition != null) {
                lastRead = book.chapters[book.lastReadChapterIndex!]
                    .substring(book.lastReadPosition!);
                lastRead = '上次阅读：$lastRead';
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  onTap: () => _openBook(book),
                  onLongPress: () => _deleteBook(book),
                  leading: Icon(
                    Icons.book,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    lastRead,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
