import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reader_settings.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../providers/reader_state.dart';

class ReaderPage extends StatelessWidget {
  final Book book;

  const ReaderPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReaderState(
        book: book,
        settingsBox: context.read<Box<ReaderSettings>>(),
      )..loadBook(),
      child: const ReaderView(),
    );
  }
}

class ReaderView extends StatelessWidget {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReaderState>();

    return Scaffold(
      body: Stack(
        children: [
          if (state.pages.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            GestureDetector(
              onTapUp: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                final tapPosition = details.globalPosition.dx;

                if (tapPosition < screenWidth / 3) {
                  context.read<ReaderState>().previousPage();
                } else if (tapPosition > screenWidth * 2 / 3) {
                  context.read<ReaderState>().nextPage();
                } else {
                  context.read<ReaderState>().toggleControls();
                }
              },
              child: const PageContent(),
            ),
          if (state.showControls) ...[
            const TopControlBar(),
            const BottomControlBar(),
          ],
        ],
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: context.read<ReaderState>().currentPage,
    );
    context.read<ReaderState>().setPageController(_pageController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReaderState>();
    return PageView.builder(
      controller: _pageController,
      itemCount: state.pages.length,
      onPageChanged: state.setCurrentPage,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 16,
          ),
          color: state.settings.backgroundColorValue,
          child: Stack(
            children: [
              Text(
                state.pages[index],
                style: state.textStyle,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Text(
                  '${index + 1}/${state.pages.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TopControlBar extends StatelessWidget {
  const TopControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<ReaderState>();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Container(
            height: kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    state.book.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showSettingsDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final state = context.read<ReaderState>();
    showModalBottomSheet(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: state,
        child: const SettingsPanel(),
      ),
    );
  }
}

class BottomControlBar extends StatelessWidget {
  const BottomControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReaderState>();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showPagePickerDialog(context),
              child: Text(
                '${state.currentPage + 1}/${state.pages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPagePickerDialog(BuildContext context) {
    final state = context.read<ReaderState>();
    final controller = TextEditingController(
      text: (state.currentPage + 1).toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: state,
        child: AlertDialog(
          title: const Text('跳转到指定页'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '请输入页码 (1-${state.pages.length})',
              errorText: null,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final pageNumber = int.tryParse(controller.text);
                if (pageNumber != null &&
                    pageNumber >= 1 &&
                    pageNumber <= state.pages.length) {
                  state.setCurrentPage(pageNumber - 1);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReaderState>();
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('字体大小'),
            subtitle: Slider(
              value: state.settings.fontSize,
              min: 12,
              max: 32,
              divisions: 20,
              label: state.settings.fontSize.round().toString(),
              onChanged: state.updateFontSize,
            ),
          ),
          ListTile(
            title: const Text('背景颜色'),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Colors.white,
                  const Color(0xFFF8F3E8), // 米色
                  const Color(0xFFE8F3E8), // 淡绿
                  const Color(0xFFE8E8F3), // 淡蓝
                ]
                    .map((color) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: InkWell(
                            onTap: () => state.updateBackgroundColor(color),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(
                                  color: state.settings.backgroundColorValue ==
                                          color
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
