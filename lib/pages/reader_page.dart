import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_novel_reader/models/book.dart';
import 'package:local_novel_reader/models/book_chapters.dart';
import 'package:local_novel_reader/models/reader_settings.dart';
import 'package:local_novel_reader/utils/text.dart';
import 'package:local_novel_reader/widgets/text_page.dart';

class ReaderPage extends StatefulWidget {
  final Book book;

  const ReaderPage({super.key, required this.book});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage>
    with SingleTickerProviderStateMixin {
  late Box<Book> bookBox;
  late Box<BookChapters> chaptersBox;
  late Box<ReaderSettings> settingsBox;
  late List<String> pages;
  late AnimationController _controller;
  late BookChapters chapters;
  PageController? pageController;
  ReaderSettings? setting;
  ValueNotifier<bool> showSetting = ValueNotifier(false);
  ValueNotifier<double> sliderVal = ValueNotifier(0);
  int nowPage = 0;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box<ReaderSettings>('settings');
    bookBox = Hive.box<Book>('books');
    chaptersBox = Hive.box<BookChapters>('book_chapters');
    chapters = chaptersBox.get(widget.book.key)!;

    _controller =
        AnimationController(vsync: this, duration: kThemeChangeDuration);
    setting = settingsBox.get('defaults');
  }

  @override
  void dispose() {
    _controller.dispose();
    pageController?.dispose();
    super.dispose();
  }

  TextStyle getTextStyle(BuildContext context) {
    return TextTheme.of(context).bodyMedium!.copyWith(
          fontSize: setting?.fontSize,
          height: setting?.lineHeight,
          inherit: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: ChapterDrawer(
        chapters: chapters,
        nowChapter: widget.book.lastReadChapterIndex,
        onChapterChange: (index) {
          widget.book.updateLastReadChapterIndex(index);
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => FutureBuilder(
                future: TextUtils.loadPages(
                  chapters.chapters[widget.book.lastReadChapterIndex],
                  getTextStyle(context),
                  constraints.maxWidth - 16,
                  constraints.maxHeight - 16,
                ),
                builder: (context, snapshpt) {
                  if (snapshpt.hasData) {
                    pages = snapshpt.data!;

                    nowPage = 0;
                    if (widget.book.lastReadPosition < 0) {
                      int pos = 0;
                      for (var i = 0; i < pages.length - 1; i++) {
                        pos += pages[i].length;
                      }
                      nowPage = pages.length - 1;
                      widget.book.lastReadPosition = pos;
                    } else {
                      int pos = 0;
                      for (final page in pages) {
                        if (pos + page.length > widget.book.lastReadPosition) {
                          break;
                        }
                        pos += page.length;
                        nowPage++;
                      }
                    }

                    pageController = PageController(
                      initialPage: nowPage,
                    );

                    return TextPage(
                      key: UniqueKey(),
                      pageController: pageController,
                      pages: pages,
                      parentConstraints: constraints,
                      textStyle: getTextStyle(context),
                      onPageChange: (index) {
                        nowPage = index;
                        updateSliderVal();

                        int pos = 0;
                        for (var i = 0; i < index; i++) {
                          pos += pages[i].length;
                        }
                        widget.book.updateLastReadPosition(pos);
                      },
                      previousChapter: () {
                        if (widget.book.lastReadChapterIndex > 0) {
                          widget.book.previousChapter();
                        }
                      },
                      nextChapter: () {
                        if (widget.book.lastReadChapterIndex <
                            chapters.chapters.length - 1) {
                          widget.book.nextChapter();
                        }
                      },
                      onOpenSetting: () {
                        updateSliderVal();
                        showSetting.value = !showSetting.value;
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            ListenableBuilder(
              listenable: showSetting,
              builder: (context, _) {
                if (showSetting.value) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
                return FadeTransition(
                  opacity: _controller,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBar(
                        title: Text(widget.book.title),
                        actions: [
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => SettingPanel(
                                  book: widget.book,
                                  chapters: chapters,
                                ),
                              );
                            },
                            icon: Icon(Icons.more_horiz),
                          ),
                        ],
                      ),
                      BottomAppBar(
                        child: ListenableBuilder(
                          listenable: sliderVal,
                          builder: (context, _) => Row(
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
                                    sliderVal.value = index;
                                    pageController?.jumpToPage(
                                      (index / 100 * (pages.length - 1))
                                          .toInt(),
                                    );
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
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void updateSliderVal() {
    if (pages.length == 1) {
      return;
    }
    sliderVal.value = nowPage / (pages.length - 1) * 100;
  }
}

class ChapterDrawer extends StatelessWidget {
  final BookChapters chapters;
  final ValueChanged<int>? onChapterChange;
  final ValueNotifier<int?> nowChapter;

  ChapterDrawer({
    super.key,
    required this.chapters,
    required int? nowChapter,
    this.onChapterChange,
  }) : nowChapter = ValueNotifier(nowChapter);

  String _formatChapterTitle(String content) {
    final trimmed = content.trim();
    if (trimmed.length > 20) {
      return '${trimmed.substring(0, 20)}...';
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        controller: ScrollController(
          keepScrollOffset: true,
        ),
        itemCount: chapters.chapters.length,
        itemBuilder: (context, index) {
          final chapterContent = chapters.chapters[index];
          return ListenableBuilder(
            builder: (context, _) {
              return ListTile(
                title: Text(
                  _formatChapterTitle(chapterContent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: index == nowChapter.value,
                onTap: () {
                  onChapterChange?.call(index);
                  Navigator.pop(context);
                },
              );
            },
            listenable: nowChapter,
          );
        },
      ),
    );
  }
}

class SettingPanel extends StatefulWidget {
  final Book book;
  final BookChapters chapters;

  const SettingPanel({
    super.key,
    required this.chapters,
    required this.book,
  });

  @override
  State<SettingPanel> createState() => _SettingPanelState();
}

class _SettingPanelState extends State<SettingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Box<ReaderSettings> box;
  late ReaderSettings setting;
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    box = Hive.box<ReaderSettings>('settings');
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setting = box.get('defaults') ?? ReaderSettings();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('字体大小'),
          subtitle: Slider(
            value: setting.fontSize,
            min: 12,
            max: 32,
            divisions: 20,
            label: setting.fontSize.round().toString(),
            onChanged: (double fontSize) {
              setting.fontSize = fontSize;
              box.put('defaults', setting);
              setState(() {});
            },
          ),
        ),
        ListTile(
          title: const Text('行间距'),
          subtitle: Slider(
            value: setting.lineHeight,
            min: 1.0,
            max: 3.0,
            divisions: 20,
            label: setting.lineHeight.toStringAsFixed(1),
            onChanged: (double lineHeight) {
              setting.lineHeight = lineHeight;
              box.put('defaults', setting);
              setState(() {});
            },
          ),
        ),
        ListTile(
          title: const Text('章节分割'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showRegexDialog(context),
          ),
        ),
      ],
    );
  }

  void _showRegexDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义章节分割'),
        content: TextField(
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: '输入正则表达式',
            helperText: r'例如: 第[a-z]章[\s\S]+?(?=第[a-z]章+|$)',
            helperMaxLines: 3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                RegExp(textEditingController.text, caseSensitive: false);
                widget.chapters
                    .parseChapters(divPattern: textEditingController.text);
                widget.chapters.save();
                widget.book
                  ..lastReadPosition = 0
                  ..lastReadChapterIndex = 0;
                widget.book.save();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('无效的正则表达式')),
                );
              }
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }
}
