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
  int currentPage = 0;
  bool showControls = false;
  PageController? pageController;

  ReaderState({
    required this.book,
    required this.settingsBox,
  }) {
    settings = settingsBox.get('default') ?? ReaderSettings();

    textStyle = TextStyle(
      fontSize: settings.fontSize,
      height: settings.lineHeight,
      color: Colors.black87,
    );
  }

  Future<void> loadPages(double width, double height) async {
    final String content = book.content;
    final List<String> newPages = [];

    final textPainter = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: width, minWidth: width);
    final lineMetrics = textPainter.computeLineMetrics();
    var nowPageHeight = 0.0;
    var cumulativeHeight = 0.0;
    final stringBuffer = StringBuffer();

    for (var i = 0; i < lineMetrics.length - 1; i++) {
      final metric = lineMetrics[i];
      cumulativeHeight += metric.height;

      final pos = textPainter.getPositionForOffset(
          Offset(metric.left + metric.width, cumulativeHeight));
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
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setCurrentPage(currentPage - 1);
    }
  }
}
