import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  int lastReadChapterIndex = 0;

  @HiveField(2)
  int lastReadPosition = 0;

  @HiveField(3)
  String content;

  @HiveField(4)
  List<String> chapters = [];

  @HiveField(5)
  DateTime? lastReadTime;

  Book({
    required this.title,
    required this.content,
  }) {
    parseChapters();
    lastReadTime = null;
  }

  void parseChapters({String? divPattern}) {
    var chapterPattern = RegExp(
        r'(第[零一二三四五六七八九十百千万\d]+[章节回集卷])?[\s\S]*?(?=第[零一二三四五六七八九十百千万\d]+[章节回集卷]|$)');
    if (divPattern != null) {
      chapterPattern = RegExp(divPattern);
    }
    final matches = chapterPattern.allMatches(content);
    if (matches.length > 1) {
      chapters = matches
          .map((m) => m.group(0)!)
          .where((chapter) {
            final trimmed = chapter.trim();
            return trimmed.isNotEmpty && !_isWhitespaceOnly(trimmed);
          })
          .map((chapter) => chapter.trim())
          .toList();

      if (chapters.isEmpty) {
        _parseChaptersByLen();
      }
    } else {
      _parseChaptersByLen();
    }
  }

  bool _isWhitespaceOnly(String text) {
    return text.replaceAll(RegExp(r'\s'), '').isEmpty;
  }

  void _parseChaptersByLen() {
    const endLen = 20000;
    const maxLen = 30000;
    final pattern = RegExp(r'\r\n|\r|\n');
    final sections = content.split(pattern);
    final buff = StringBuffer();
    for (final sec in sections) {
      if (_isWhitespaceOnly(sec)) continue;

      buff.writeln(sec);
      if (buff.length >= endLen && buff.length < maxLen) {
        chapters.add(buff.toString());
        buff.clear();
      } else if (buff.length >= maxLen) {
        final content = buff.toString();
        buff.clear();
        for (var start = 0; start < buff.length; start += maxLen) {
          var end = start + maxLen;
          if (end > buff.length) {
            end = buff.length;
          }
          chapters.add(content.substring(start, end));
        }
      }
    }
    if (buff.isNotEmpty) {
      chapters.add(buff.toString());
    }
  }

  void updateLastReadTime() {
    lastReadTime = DateTime.now();
    save();
  }
}
