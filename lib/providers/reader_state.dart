import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/book.dart';
import '../models/reader_settings.dart';
import 'dart:io';

class ReaderState extends ChangeNotifier {
  final Book book;
  final Box<ReaderSettings> settingsBox;
  late ReaderSettings settings;
  List<String> pages = [];
  int currentPage = 0;
  bool showControls = false;
  TextStyle textStyle;
  PageController? pageController;

  ReaderState({
    required this.book,
    required this.settingsBox,
  }) : textStyle = TextStyle(
          fontSize: 18,
          height: 1.5,
          color: Colors.black87,
        ) {
    settings = settingsBox.get('default') ?? ReaderSettings();
    currentPage = book.lastReadPosition;
    _updateTextStyle();
  }

  void _updateTextStyle() {
    textStyle = TextStyle(
      fontSize: settings.fontSize,
      height: 1.5,
      color: Colors.black87,
    );
    notifyListeners();
  }

  void toggleControls() {
    showControls = !showControls;
    notifyListeners();
  }

  void updateFontSize(double size) {
    settings.fontSize = size;
    _updateTextStyle();
    saveSettings();
    loadBook();
  }

  void updateBackgroundColor(Color color) {
    settings.backgroundColorValue = color;
    notifyListeners();
    saveSettings();
  }

  void saveSettings() {
    settingsBox.put('default', settings);
  }

  void saveBook() {
    book.save();
  }

  void setCurrentPage(int page) {
    currentPage = page;
    book.lastReadPosition = page;
    pageController?.animateToPage(
      page,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
    saveBook();
    notifyListeners();
  }

  Future<void> loadBook() async {
    pages = [];
    notifyListeners();

    final String content = await File(book.filePath).readAsString();
    final List<String> newPages = [];

    await Future(() async {
      int start = 0;
      while (start < content.length) {
        int size = calculateWordsPerPage(content.substring(start));
        if (size <= 0) break;

        int end = start + size;
        if (end > content.length) end = content.length;

        newPages.add(content.substring(start, end));
        start = end;
      }
    });

    pages = newPages;
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

  int calculateWordsPerPage(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    // 考虑页码的高度和边距
    final double pageHeight =
        WidgetsBinding.instance.window.physicalSize.height /
                WidgetsBinding.instance.window.devicePixelRatio -
            kToolbarHeight -
            32 - // 上下padding
            24; // 页码高度和间距
    final double pageWidth = WidgetsBinding.instance.window.physicalSize.width /
            WidgetsBinding.instance.window.devicePixelRatio -
        32;

    int start = 0;
    int end = text.length;

    while (start < end) {
      int mid = (start + end) ~/ 2;
      String testText = text.substring(0, mid);

      textPainter.text = TextSpan(text: testText, style: textStyle);
      textPainter.layout(maxWidth: pageWidth);

      if (textPainter.height <= pageHeight) {
        start = mid + 1;
      } else {
        end = mid;
      }
    }

    return start - 1;
  }

  void setPageController(PageController controller) {
    pageController = controller;
  }
}
