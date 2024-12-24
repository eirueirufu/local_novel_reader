import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  int lastReadPosition;

  @HiveField(3)
  List<Bookmark> bookmarks;

  Book({
    required this.title,
    required this.filePath,
    this.lastReadPosition = 0,
    List<Bookmark>? bookmarks,
  }) : bookmarks = bookmarks ?? [];
}

@HiveType(typeId: 1)
class Bookmark {
  @HiveField(0)
  final int pageIndex;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createTime;

  Bookmark({
    required this.pageIndex,
    required this.content,
    DateTime? createTime,
  }) : createTime = createTime ?? DateTime.now();
}
