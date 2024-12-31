import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  int lastReadPosition;

  @HiveField(2)
  String content;

  Book({
    required this.title,
    this.lastReadPosition = 0,
    required this.content,
  });
}
