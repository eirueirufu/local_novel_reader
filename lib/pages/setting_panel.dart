import 'package:flutter/material.dart';

class SettingPanel extends StatefulWidget {
  final List<String> pages;
  final TextStyle textStyle;
  final BoxConstraints parentConstraints;
  final ValueChanged<int>? onPageChange;
  final int initPage;

  SettingPanel({
    super.key,
    required this.pages,
    required this.textStyle,
    required this.parentConstraints,
    this.onPageChange,
    required this.initPage,
  });

  @override
  State<SettingPanel> createState() => _SettingPanelState();
}

class _SettingPanelState extends State<SettingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ScrollController? listController;
  double? totalWidth;
  late ValueNotifier<double> sliderVal;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    sliderVal =
        ValueNotifier((widget.initPage + 1) / widget.pages.length * 100);
  }

  @override
  void dispose() {
    _controller.dispose();
    sliderVal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Placeholder(),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context)
                ..pop()
                ..pop();
            }),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                showBottomSheet(
                  context: context,
                  builder: (context) => Placeholder(),
                );
              },
              icon: Icon(Icons.more),
            );
          }),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final initOffset =
            widget.initPage * (widget.parentConstraints.maxWidth) +
                widget.initPage;

        totalWidth ??= widget.pages.isEmpty
            ? 0
            : widget.pages.length * (widget.parentConstraints.maxWidth + 1) - 1;
        listController?.dispose();
        listController = ScrollController(
          initialScrollOffset: initOffset,
        );
        listController!.addListener(() {
          double scrollPercentage =
              (listController!.offset / totalWidth!) * 100;
          sliderVal.value = scrollPercentage.clamp(0.0, 100.0);
        });
        return ListView.separated(
          physics: BouncingScrollPhysics(),
          controller: listController,
          separatorBuilder: (context, index) => VerticalDivider(
            width: 1,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: widget.pages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                widget.onPageChange?.call(index);
                Navigator.of(context).pop();
              },
              child: Hero(
                tag: 'page$index',
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: widget.parentConstraints.maxWidth,
                  height: widget.parentConstraints.maxHeight,
                  child: Text(
                    widget.pages[index],
                    style: widget.textStyle,
                  ),
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomAppBar(
        child: ListenableBuilder(
          listenable: sliderVal,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${sliderVal.value.toInt()}%"),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 100,
                    value: sliderVal.value,
                    onChanged: (index) {
                      // sliderVal.value = index;
                      listController?.jumpTo((totalWidth ?? 0) * index / 100);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: Icon(Icons.list),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
