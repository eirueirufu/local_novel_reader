import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  List<String> pages = [];
  final TextStyle textStyle;
  final ValueChanged<int>? onOffsetChange;
  final ValueChanged<int>? onPageChange;
  PageController? pageController;
  final VoidCallback? onOpenSetting;
  final VoidCallback? previousChapter;
  final VoidCallback? nextChapter;

  TextPage({
    super.key,
    required this.pages,
    required this.textStyle,
    this.onOffsetChange,
    this.pageController,
    this.onPageChange,
    this.onOpenSetting,
    this.previousChapter,
    this.nextChapter,
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
    currentPage = pageController.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTapDown: (details) {
          if (details.localPosition.dx < constraints.maxWidth / 3) {
            if (currentPage <= 0) {
              widget.previousChapter?.call();
            } else {
              pageController.previousPage(
                  duration: kThemeChangeDuration, curve: Curves.linear);
            }
          } else if (details.localPosition.dx > constraints.maxWidth * 2 / 3) {
            if (currentPage >= widget.pages.length - 1) {
              widget.nextChapter?.call();
            } else {
              pageController.nextPage(
                  duration: kThemeChangeDuration, curve: Curves.linear);
            }
          } else {
            widget.onOpenSetting?.call();
          }
        },
        child: PageView.builder(
          physics: BouncingScrollPhysics(),
          controller: pageController,
          itemCount: widget.pages.length,
          itemBuilder: (context, index) {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Text(
                widget.pages[index],
                style: widget.textStyle,
              ),
            );
          },
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
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.pageController == null) {
      pageController.dispose();
    }
  }
}
