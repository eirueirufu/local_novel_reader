import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  List<String> pages = [];
  final TextStyle textStyle;
  final ValueChanged<int>? onOffsetChange;
  final ValueChanged<int>? onPageChange;
  PageController? pageController;

  TextPage({
    super.key,
    required this.pages,
    required this.textStyle,
    this.onOffsetChange,
    this.pageController,
    this.onPageChange,
  });

  @override
  State<StatefulWidget> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  int currentPage = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = widget.pageController ?? PageController();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: PageScrollPhysics(),
      controller: pageController,
      itemBuilder: (context, index) => Hero(
        tag: 'page$index',
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Text(
            widget.pages[index],
            style: widget.textStyle,
          ),
        ),
      ),
      itemCount: widget.pages.length,
      onPageChanged: (index) {
        currentPage = index;
        widget.onPageChange?.call(index);
        if (widget.onOffsetChange != null) {
          int offset = 0;
          for (int i = 0; i < index; i++) {
            offset += widget.pages[i].length;
          }
          widget.onOffsetChange!(offset);
        }
      },
    );
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      pageController.dispose();
    }
    super.dispose();
  }
}
