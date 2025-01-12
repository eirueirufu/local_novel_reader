import 'package:flutter/material.dart';

class TextUtils {
  static Future<List<String>> loadPages(
    String content,
    TextStyle textStyle,
    double width,
    double height,
  ) async {
    final List<String> pages = [];

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
        pages.add(stringBuffer.toString());
        stringBuffer.clear();
        stringBuffer.writeln(line);
        nowPageHeight = metric.height;
      }
    }

    if (stringBuffer.isNotEmpty) {
      pages.add(stringBuffer.toString());
    }

    return pages;
  }
}
