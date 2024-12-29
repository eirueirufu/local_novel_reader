import 'package:flutter/material.dart';

class TextPagePainter extends CustomPainter {
  final String content;
  final TextStyle textStyle;

  TextPagePainter({
    required this.content,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainter.layout(maxWidth: size.width, minWidth: size.width);
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
