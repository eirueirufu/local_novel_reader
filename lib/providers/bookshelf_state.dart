import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/book.dart';
import '../models/reader_settings.dart';

class BookshelfState extends ChangeNotifier {
  final Box<Book> booksBox;
  final Box<ReaderSettings> settingsBox;

  BookshelfState({
    required this.booksBox,
    required this.settingsBox,
  });

  List<Book> get books {
    final bookList = booksBox.values.toList()
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

      await booksBox.add(book);
      notifyListeners();
    }
  }

  Future<void> deleteBook(Book book) async {
    await book.delete();
    notifyListeners();
  }

  ReaderSettings getSettings() {
    return settingsBox.get('default') ?? ReaderSettings();
  }

  void refresh() {
    notifyListeners();
  }
}
