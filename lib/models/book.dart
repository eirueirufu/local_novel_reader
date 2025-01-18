import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject with ChangeNotifier {
  @HiveField(0)
  final String title;

  @HiveField(1)
  int lastReadChapterIndex = 0;

  @HiveField(2)
  int lastReadPosition = 0;

  @HiveField(3)
  DateTime? lastReadTime;

  Book({
    required this.title,
  }) {
    lastReadTime = null;
  }

  void updateLastReadTime() {
    lastReadTime = DateTime.now();
    save();
  }

  void updateLastReadPosition(int index) {
    lastReadPosition = index;
    updateLastReadTime();
  }

  void previousChapter() {
    lastReadPosition = -1;
    lastReadChapterIndex--;
    updateLastReadTime();
    notifyListeners();
  }

  void nextChapter() {
    lastReadPosition = 0;
    lastReadChapterIndex++;
    updateLastReadTime();
    notifyListeners();
  }

  void updateLastReadChapterIndex(int index) {
    lastReadPosition = 0;
    lastReadChapterIndex = index;
    updateLastReadTime();
    notifyListeners();
  }
}
