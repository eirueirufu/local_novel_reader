import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/book.dart';
import '../models/reader_settings.dart';

class ReaderState extends ChangeNotifier {
  final Book book;
  final Box<ReaderSettings> settingsBox;
  late ReaderSettings settings;
  late TextStyle textStyle;
  List<String> pages = [];
  int currentChapter = 0;
  int currentPage = 0;
  bool showControls = false;
  PageController? pageController;
  bool back = false;
  final textEditingController = TextEditingController();

  ReaderState({
    required this.book,
    required this.settingsBox,
  }) {
    settings = settingsBox.get('default') ?? ReaderSettings();
    if (book.lastReadChapterIndex == null || book.lastReadPosition == null) {
      book.lastReadChapterIndex = 0;
      book.lastReadPosition = 0;
      saveBook();
    }
    currentChapter = book.lastReadChapterIndex!;

    book.updateLastReadTime();

    textStyle = TextStyle(
      fontSize: settings.fontSize,
      height: settings.lineHeight,
      color: Colors.black87,
    );
  }

  String get textPlaceholder {
    int assumeLen = 5000;
    int totalLen = 0;
    for (final page in pages) {
      totalLen += page.length;
    }
    if (pages.isNotEmpty) {
      assumeLen = pages[0].length;
    }

    final nowChapter = book.chapters[book.lastReadChapterIndex!];
    final cptLen = nowChapter.length;

    if (assumeLen > cptLen) {
      assumeLen = cptLen;
    }
    if (back) {
      return nowChapter.substring(nowChapter.length - totalLen % assumeLen);
    }
    return nowChapter.substring(0, assumeLen);
  }

  Future<void> loadPages(double width, double height) async {
    final String content = book.chapters[book.lastReadChapterIndex ?? 0];
    final List<String> newPages = [];

    final textPainter = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: width, minWidth: width);
    final lineMetrics = textPainter.computeLineMetrics();
    var nowPageHeight = 0.0;
    final stringBuffer = StringBuffer();

    for (var i = 0; i < lineMetrics.length; i++) {
      final metric = lineMetrics[i];
      final pos = textPainter.getPositionForOffset(
          Offset(metric.left + metric.width, metric.baseline));
      final boundary = textPainter.getLineBoundary(pos);
      final line = content.substring(boundary.start, boundary.end);

      if (nowPageHeight + metric.height <= height) {
        stringBuffer.writeln(line);
        nowPageHeight += metric.height;
      } else {
        newPages.add(stringBuffer.toString());
        stringBuffer.clear();
        stringBuffer.writeln(line);
        nowPageHeight = metric.height;
      }
    }

    if (stringBuffer.isNotEmpty) {
      newPages.add(stringBuffer.toString());
    }

    pages = newPages;
  }

  void toggleControls() {
    showControls = !showControls;
    notifyListeners();
  }

  void updateFontSize(double fontSize) {
    settings.fontSize = fontSize;
    textStyle = TextStyle(
      fontSize: settings.fontSize,
      height: settings.lineHeight,
      color: Colors.black87,
    );
    saveSettings();
    notifyListeners();
  }

  void updateLineHeight(double lineHeight) {
    settings.lineHeight = lineHeight;
    textStyle = TextStyle(
      fontSize: settings.fontSize,
      height: settings.lineHeight,
      color: Colors.black87,
    );
    saveSettings();
    notifyListeners();
  }

  void updateBackgroundColor(Color color) {
    settings.backgroundColorValue = color;
    saveSettings();
    notifyListeners();
  }

  void saveSettings() {
    settingsBox.put('default', settings);
  }

  void saveBook() {
    book.save();
  }

  void setCurrentPage(int page) {
    currentPage = page;
    int pos = 0;
    for (var i = 0; i < page; i++) {
      pos += pages[i].length;
    }
    book.lastReadPosition = pos;
    pageController?.animateToPage(
      page,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
    saveBook();
    notifyListeners();
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      setCurrentPage(currentPage + 1);
    } else if (currentChapter < book.chapters.length - 1) {
      setCurrentChapter(currentChapter + 1);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setCurrentPage(currentPage - 1);
    } else if (currentChapter > 0) {
      setCurrentChapter(currentChapter - 1, back: true);
    }
  }

  void setCurrentChapter(int index, {bool back = false}) {
    this.back = back;
    if (index < 0 || index >= book.chapters.length) {
      return;
    }
    currentChapter = index;
    book.lastReadChapterIndex = index;
    book.lastReadPosition = 0;
    book.updateLastReadTime();
    saveBook();
    notifyListeners();
  }

  void updateChapterRegex(String text) {
    book.parseChapters(divPattern: text);
    book.lastReadChapterIndex = null;
    book.lastReadPosition = null;

    saveBook();
    notifyListeners();
  }

  @override
  void dispose() {
    pageController?.dispose();
    textEditingController.dispose();
    super.dispose();
  }
}
