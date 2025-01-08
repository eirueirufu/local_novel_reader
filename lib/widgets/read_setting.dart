import 'package:flutter/material.dart';

class ReadSetting extends StatefulWidget {
  final String title;
  final AnimationController? controller;

  const ReadSetting({
    super.key,
    required this.title,
    this.controller,
  });

  @override
  State<ReadSetting> createState() => _ReadSettingState();
}

class _ReadSettingState extends State<ReadSetting>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
        );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: _controller,
          child: AppBar(
            title: Text(widget.title),
          ),
        ),
        Expanded(child: Container()),
        FadeTransition(
          opacity: _controller,
          child: BottomAppBar(
            child: Placeholder(),
          ),
        ),
      ],
    );
  }
}
