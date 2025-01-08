import 'package:flutter/material.dart';

class TextPages extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final ValueChanged<int>? onOffsetChange;
  final int? lastIndex;

  const TextPages({
    super.key,
    required this.text,
    required this.textStyle,
    this.lastIndex,
    this.onOffsetChange,
  }) : assert(text.length < 20000);

  @override
  State<StatefulWidget> createState() => _TextPagesState();
}

class _TextPagesState extends State<TextPages> {
  List<String> pages = [];
  int currentPage = 0;
  PageController? pageController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => FutureBuilder(
        future: loadPages(constraints),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            pages = snapshot.data!;
            if (widget.lastIndex != null) {
              int pos = 0;
              for (final page in pages) {
                if (pos + page.length > widget.lastIndex!) {
                  break;
                }
                pos += page.length;
                currentPage++;
              }
            }
            pageController = PageController(initialPage: currentPage);

            return PageView.builder(
              physics: PageScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, index) => GestureDetector(
                onTapUp: (details) {
                  final tapPosition = details.localPosition.dx;
                  if (tapPosition < constraints.maxWidth / 3) {
                    pageController?.previousPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.linear,
                    );
                  } else {
                    pageController?.nextPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.linear,
                    );
                  }
                },
                child: Text(
                  pages[index],
                  style: widget.textStyle,
                ),
              ),
              itemCount: pages.length,
              onPageChanged: (index) {
                currentPage = index;
                if (widget.onOffsetChange != null) {
                  int offset = 0;
                  for (int i = 0; i < index; i++) {
                    offset += pages[i].length;
                  }
                  widget.onOffsetChange!(offset);
                }
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  Future<List<String>> loadPages(BoxConstraints constraints) async {
    final text = widget.text;
    final textStyle = widget.textStyle;
    final List<String> loadPages = [];
    final size = Size(constraints.maxWidth, constraints.maxHeight);

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: textStyle),
    );
    textPainter.layout(minWidth: size.width, maxWidth: size.width);
    final metrics = textPainter.computeLineMetrics();
    final pageBuff = StringBuffer();
    double nowHeight = 0;

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final pos = textPainter.getPositionForOffset(
          Offset(metric.left + metric.width, metric.baseline));
      final boundary = textPainter.getLineBoundary(pos);
      final line = text.substring(boundary.start, boundary.end);

      if (nowHeight + metric.height <= size.height) {
        pageBuff.writeln(line);
        nowHeight += metric.height;
      } else {
        loadPages.add(pageBuff.toString());
        pageBuff.clear();
        pageBuff.writeln(line);
        nowHeight = metric.height;
      }
    }
    if (pageBuff.isNotEmpty) {
      loadPages.add(pageBuff.toString());
    }

    textPainter.dispose();
    return loadPages;
  }
}
