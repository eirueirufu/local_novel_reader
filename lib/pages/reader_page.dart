import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_novel_reader/models/book.dart';
import 'package:local_novel_reader/models/reader_settings.dart';
import 'package:local_novel_reader/pages/reader_list.dart';
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
  late Box<ReaderSettings> box;
  late List<String> pages;
  late AnimationController _controller;
  PageController? pageController;
  ReaderSettings? setting;
  int nowPage = 0;

  @override
  void initState() {
    super.initState();
    box = Hive.box<ReaderSettings>('settings');
    _controller = AnimationController(vsync: this, duration: Durations.medium1);
  }

  @override
  void dispose() {
    widget.book.save();
    _controller.dispose();
    pageController?.dispose();
    super.dispose();
  }

  TextStyle getTextStyle(BuildContext context) {
    return TextTheme.of(context).bodyMedium!.copyWith(
          fontSize: setting?.fontSize,
          height: setting?.lineHeight,
        );
  }

  @override
  Widget build(BuildContext context) {
    setting = box.get('defaults');

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => FutureBuilder(
          future: TextUtils.loadPages(
            widget.book.chapters[widget.book.lastReadChapterIndex ?? 0],
            getTextStyle(context),
            constraints.maxWidth,
            constraints.maxHeight,
          ),
          builder: (context, snapshpt) {
            if (snapshpt.hasData) {
              pages = snapshpt.data!;

              nowPage = 0;
              int pos = 0;
              for (final page in pages) {
                if (pos + page.length > (widget.book.lastReadPosition ?? 0)) {
                  break;
                }
                pos += page.length;
                nowPage++;
              }
              pageController ??= PageController(
                keepPage: true,
                initialPage: nowPage,
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return ReaderList(
                          book: widget.book,
                          pages: pages,
                          textStyle: getTextStyle(context),
                          parentConstraints: constraints,
                          initPage: nowPage,
                          onPageChange: (index) {
                            pageController?.jumpToPage(index);
                            int pos = 0;
                            for (var i = 0; i < index; i++) {
                              pos += pages[i].length;
                            }
                            widget.book.lastReadPosition = pos;
                          },
                          onChapterChange: (index) {
                            widget.book.lastReadChapterIndex = index;
                            widget.book.save();
                          },
                        );
                      },
                    ),
                  );
                },
                child: TextPage(
                  pageController: pageController,
                  pages: pages,
                  textStyle: getTextStyle(context),
                  onPageChange: (value) {
                    nowPage = value;
                  },
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

// class _ReaderState {
//   final TextStyle textStyle;
//   final int currentChapter;
//   final List<String> chapters;

//   _ReaderState(this.textStyle, this.currentChapter, this.chapters);

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is _ReaderState &&
//           runtimeType == other.runtimeType &&
//           textStyle == other.textStyle &&
//           currentChapter == other.currentChapter &&
//           _listEquals(chapters, other.chapters);

//   bool _listEquals(List<String> a, List<String> b) {
//     if (identical(a, b)) return true;
//     if (a.length != b.length) return false;
//     for (int i = 0; i < a.length; i++) {
//       if (a[i] != b[i]) return false;
//     }
//     return true;
//   }

//   @override
//   int get hashCode =>
//       Object.hash(textStyle, currentChapter, Object.hashAll(chapters));
// }

// class ReaderPage2 extends StatelessWidget {
//   final Book book;
//   const ReaderPage2({super.key, required this.book});

//   @override
//   Widget build(BuildContext context) {
//     final state = context.read<ReaderState>();
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       endDrawer: ChapterDrawer(),
//       body: Selector<ReaderState, Color>(
//           selector: (_, state) => state.settings.backgroundColorValue,
//           builder: (context, color, _) {
//             return Container(
//               color: color,
//               child: SafeArea(
//                 child: Stack(
//                   children: [
//                     Selector<ReaderState, _ReaderState>(
//                       builder: (context, value, _) {
//                         return LayoutBuilder(
//                           builder: (context, constraints) {
//                             final width = constraints.maxWidth;
//                             final height = constraints.maxHeight;
//                             return FutureBuilder(
//                               future: state.loadPages(width, height),
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.done) {
//                                   final state = context.read<ReaderState>();
//                                   int initPage = 0;

//                                   if (state.back) {
//                                     int len = 0;
//                                     for (var i = 0;
//                                         i < state.pages.length - 1;
//                                         i++) {
//                                       len += state.pages[i].length;
//                                     }
//                                     initPage = state.pages.length - 1;
//                                     state.book.lastReadPosition = len;
//                                     state.saveBook();
//                                   } else {
//                                     int pos = 0;
//                                     for (final page in state.pages) {
//                                       if (pos + page.length >
//                                           (book.lastReadPosition ?? 0)) {
//                                         break;
//                                       }
//                                       pos += page.length;
//                                       initPage++;
//                                     }
//                                   }

//                                   state.currentPage = initPage;
//                                   state.pageController = PageController(
//                                     initialPage: initPage,
//                                   );
//                                   return Stack(
//                                     children: [
//                                       GestureDetector(
//                                         onTapUp: (details) {
//                                           final tapPosition =
//                                               details.localPosition.dx;

//                                           if (tapPosition < width / 3) {
//                                             state.previousPage();
//                                           } else if (tapPosition >
//                                               width * 2 / 3) {
//                                             state.nextPage();
//                                           } else {
//                                             state.toggleControls();
//                                           }
//                                         },
//                                         onHorizontalDragEnd: (details) {
//                                           if (details.primaryVelocity! > 0) {
//                                             state.previousPage();
//                                           } else if (details.primaryVelocity! <
//                                               0) {
//                                             state.nextPage();
//                                           }
//                                         },
//                                         child: PageView.builder(
//                                           physics:
//                                               const NeverScrollableScrollPhysics(),
//                                           controller: state.pageController,
//                                           itemCount: state.pages.length,
//                                           itemBuilder: (context, index) {
//                                             return Selector<ReaderState, Color>(
//                                               builder: (context, color, _) {
//                                                 return Stack(
//                                                   children: [
//                                                     CustomPaint(
//                                                       size: Size(width, height),
//                                                       painter: TextPagePainter(
//                                                         content:
//                                                             state.pages[index],
//                                                         textStyle:
//                                                             state.textStyle,
//                                                       ),
//                                                     ),
//                                                     Positioned(
//                                                       left: 0,
//                                                       right: 0,
//                                                       bottom: 0,
//                                                       child: Text(
//                                                         '${index + 1}/${state.pages.length}',
//                                                         style: const TextStyle(
//                                                           color: Colors.grey,
//                                                           fontSize: 14,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 );
//                                               },
//                                               selector: (_, state) => state
//                                                   .settings
//                                                   .backgroundColorValue,
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       Selector<ReaderState, bool>(
//                                         builder: (context, show, _) {
//                                           if (show) {
//                                             return const BottomControlBar();
//                                           } else {
//                                             return Container();
//                                           }
//                                         },
//                                         selector: (_, state) =>
//                                             state.showControls,
//                                       ),
//                                     ],
//                                   );
//                                 } else {
//                                   return CustomPaint(
//                                     size: Size(width, height),
//                                     painter: TextPagePainter(
//                                         content: state.textPlaceholder,
//                                         textStyle: state.textStyle),
//                                   );
//                                 }
//                               },
//                             );
//                           },
//                         );
//                       },
//                       selector: (_, state) => _ReaderState(state.textStyle,
//                           state.currentChapter, state.book.chapters),
//                     ),
//                     Selector<ReaderState, bool>(
//                       builder: (context, show, _) {
//                         if (show) {
//                           return const TopControlBar();
//                         } else {
//                           return Container();
//                         }
//                       },
//                       selector: (_, state) => state.showControls,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }
// }

// class TopControlBar extends StatelessWidget {
//   const TopControlBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final state = context.read<ReaderState>();
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         child: SafeArea(
//           child: Container(
//             height: kToolbarHeight,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//                 Expanded(
//                   child: Text(
//                     state.book.title,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.menu),
//                   onPressed: () => Scaffold.of(context).openEndDrawer(),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.settings),
//                   onPressed: () => _showSettingsDialog(context),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSettingsDialog(BuildContext context) {
//     final state = context.read<ReaderState>();
//     showModalBottomSheet(
//       context: context,
//       builder: (dialogContext) => ChangeNotifierProvider.value(
//         value: state,
//         child: const SettingsPanel(),
//       ),
//     );
//   }
// }

// class _ButtomBarState {
//   final int currentPage;
//   final int pageLen;

//   _ButtomBarState({required this.currentPage, required this.pageLen});

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is _ButtomBarState &&
//           runtimeType == other.runtimeType &&
//           currentPage == other.currentPage &&
//           pageLen == other.pageLen;

//   @override
//   int get hashCode => Object.hash(currentPage, pageLen);
// }

// class BottomControlBar extends StatelessWidget {
//   const BottomControlBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<ReaderState, _ButtomBarState>(
//         builder: (context, state, _) => Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.black.withOpacity(0.6),
//                 padding: EdgeInsets.only(
//                   left: 16,
//                   right: 16,
//                   top: 16,
//                   bottom: MediaQuery.of(context).padding.bottom + 16,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () => _showPagePickerDialog(context),
//                       child: Text(
//                         '${state.currentPage + 1}/${state.pageLen}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         selector: (context, state) => _ButtomBarState(
//             currentPage: state.currentPage, pageLen: state.pages.length));
//   }

//   void _showPagePickerDialog(BuildContext context) {
//     final state = context.read<ReaderState>();
//     state.textEditingController.text = (state.currentPage + 1).toString();
//     showDialog(
//       context: context,
//       builder: (dialogContext) => ChangeNotifierProvider.value(
//         value: state,
//         child: AlertDialog(
//           title: const Text('跳转到指定页'),
//           content: TextField(
//             controller: state.textEditingController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               hintText: '请输入页码 (1-${state.pages.length})',
//               errorText: null,
//             ),
//             autofocus: true,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('取消'),
//             ),
//             TextButton(
//               onPressed: () {
//                 final pageNumber =
//                     int.tryParse(state.textEditingController.text);
//                 if (pageNumber != null &&
//                     pageNumber >= 1 &&
//                     pageNumber <= state.pages.length) {
//                   state.setCurrentPage(pageNumber - 1);
//                   Navigator.pop(dialogContext);
//                 }
//               },
//               child: const Text('确定'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SettingsPanel extends StatelessWidget {
//   const SettingsPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final state = context.watch<ReaderState>();
//     return Selector<ReaderState, ReaderSettings>(
//         builder: (context, settings, _) => Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).padding.bottom,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     title: const Text('字体大小'),
//                     subtitle: Slider(
//                       value: state.settings.fontSize,
//                       min: 12,
//                       max: 32,
//                       divisions: 20,
//                       label: state.settings.fontSize.round().toString(),
//                       onChanged: (double fontSize) {
//                         state.updateFontSize(fontSize);
//                       },
//                     ),
//                   ),
//                   ListTile(
//                     title: const Text('行间距'),
//                     subtitle: Slider(
//                       value: state.settings.lineHeight,
//                       min: 1.0,
//                       max: 3.0,
//                       divisions: 20,
//                       label: state.settings.lineHeight.toStringAsFixed(1),
//                       onChanged: (double lineHeight) {
//                         state.updateLineHeight(lineHeight);
//                       },
//                     ),
//                   ),
//                   ListTile(
//                     title: const Text('背景颜色'),
//                     subtitle: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         children: [
//                           Colors.white,
//                           const Color(0xFFF8F3E8), // 米色
//                           const Color(0xFFE8F3E8), // 淡绿
//                           const Color(0xFFE8E8F3), // 淡蓝
//                           const Color(0xFFF5E6E6), // 淡粉
//                           const Color(0xFFE6F5F5), // 淡青
//                           const Color(0xFFF5F5E6), // 淡黄
//                           const Color(0xFFEEEEEE), // 浅灰
//                           const Color(0xFFE0E0E0), // 中灰
//                           const Color(0xFF303030), // 深色模式
//                         ]
//                             .map((color) => Padding(
//                                   padding: const EdgeInsets.all(4),
//                                   child: InkWell(
//                                     onTap: () =>
//                                         state.updateBackgroundColor(color),
//                                     child: Container(
//                                       width: 40,
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         color: color,
//                                         border: Border.all(
//                                           color: state.settings
//                                                       .backgroundColorValue ==
//                                                   color
//                                               ? Colors.blue
//                                               : Colors.grey,
//                                           width: 2,
//                                         ),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                   ),
//                   ListTile(
//                     title: const Text('章节分割'),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.edit),
//                       onPressed: () => _showRegexDialog(context, state),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         selector: (context, state) => state.settings);
//   }

//   void _showRegexDialog(BuildContext context, ReaderState state) {
//     final controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('自定义章节分割'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             hintText: '输入正则表达式',
//             helperText: r'例如: 第[a-z]章[\s\S]+?(?=第[a-z]章+|$)',
//             helperMaxLines: 3,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               try {
//                 RegExp(controller.text, caseSensitive: false);
//                 state.updateChapterRegex(controller.text);
//                 Navigator.pop(context);
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('无效的正则表达式')),
//                 );
//               }
//             },
//             child: const Text('更新'),
//           ),
//         ],
//       ),
//     ).then((_) => controller.dispose());
//   }
// }
