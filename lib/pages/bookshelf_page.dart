import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../providers/bookshelf_state.dart';
import '../providers/reader_state.dart';
import 'reader_page.dart';
import 'package:provider/provider.dart';

class BookshelfPage extends StatelessWidget {
  const BookshelfPage({super.key});

  void _openBook(BuildContext context, Book book) {
    final bookshelfState = context.read<BookshelfState>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ReaderState(
            book: book,
            settingsBox: bookshelfState.settingsBox,
          ),
          child: ReaderPage(book: book),
        ),
      ),
    ).then((_) {
      // 当阅读页面返回时，刷新书架
      bookshelfState.refresh();
    });
  }

  Future<void> _deleteBook(BuildContext context, Book book) async {
    final state = context.read<BookshelfState>();
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
      await state.deleteBook(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的书架'),
      ),
      body: Consumer<BookshelfState>(
        builder: (context, state, _) {
          final books = state.books;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              var lastRead = '暂未阅读';

              if (book.lastReadTime != null) {
                lastRead =
                    '上次阅读：${DateFormat('yyyy-MM-dd HH:mm').format(book.lastReadTime!)}';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  onTap: () => _openBook(context, book),
                  onLongPress: () => _deleteBook(context, book),
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
        onPressed: () => context.read<BookshelfState>().importBook(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
