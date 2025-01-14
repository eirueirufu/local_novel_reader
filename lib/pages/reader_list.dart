// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:local_novel_reader/models/book.dart';
// import 'package:local_novel_reader/models/reader_settings.dart';

// class ReaderList extends StatefulWidget {
//   final Book book;
//   final List<String> pages;
//   final TextStyle textStyle;
//   final BoxConstraints parentConstraints;
//   final ValueChanged<int>? onPageChange;
//   final ValueChanged<int>? onChapterChange;
//   final int initPage;

//   ReaderList({
//     super.key,
//     required this.pages,
//     required this.textStyle,
//     required this.parentConstraints,
//     required this.initPage,
//     required this.book,
//     this.onPageChange,
//     this.onChapterChange,
//   });

//   @override
//   State<ReaderList> createState() => _ReaderListState();
// }

// class _ReaderListState extends State<ReaderList>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   ScrollController? listController;
//   double? totalWidth;
//   late ValueNotifier<double> sliderVal;

//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 200));
//     sliderVal =
//         ValueNotifier((widget.initPage + 1) / widget.pages.length * 100);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     sliderVal.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       endDrawer: ChapterDrawer(
//         book: widget.book,
//         nowChapter: widget.book.lastReadChapterIndex,
//         onChapterChange: widget.onChapterChange,
//       ),
//       appBar: AppBar(
//         leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.of(context)
//                 ..pop()
//                 ..pop();
//             }),
//         actions: [
//           Builder(builder: (context) {
//             return IconButton(
//               onPressed: () {
//                 showBottomSheet(
//                   context: context,
//                   builder: (context) => SettingPanel(),
//                 );
//               },
//               icon: Icon(Icons.more),
//             );
//           }),
//         ],
//       ),
//       body: LayoutBuilder(builder: (context, constraints) {
//         final initOffset =
//             widget.initPage * (widget.parentConstraints.maxWidth) +
//                 widget.initPage;

//         totalWidth ??= widget.pages.isEmpty
//             ? 0
//             : widget.pages.length * (widget.parentConstraints.maxWidth + 1) - 1;
//         listController?.dispose();
//         listController = ScrollController(
//           initialScrollOffset: initOffset,
//         );
//         listController!.addListener(() {
//           double scrollPercentage =
//               (listController!.offset / totalWidth!) * 100;
//           sliderVal.value = scrollPercentage.clamp(0.0, 100.0);
//         });
//         return ListView.separated(
//           physics: BouncingScrollPhysics(),
//           controller: listController,
//           separatorBuilder: (context, index) => VerticalDivider(
//             width: 1,
//           ),
//           scrollDirection: Axis.horizontal,
//           itemCount: widget.pages.length,
//           itemBuilder: (context, index) {
//             return GestureDetector(
//               onTap: () {
//                 widget.onPageChange?.call(index);
//                 Navigator.of(context).pop();
//               },
//               child: Hero(
//                 tag: 'page$index',
//                 child: Container(
//                   color: Theme.of(context).scaffoldBackgroundColor,
//                   width: widget.parentConstraints.maxWidth,
//                   height: widget.parentConstraints.maxHeight,
//                   child: Text(
//                     widget.pages[index],
//                     style: widget.textStyle,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//       bottomNavigationBar: BottomAppBar(
//         child: ListenableBuilder(
//           listenable: sliderVal,
//           builder: (context, _) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text("${sliderVal.value.toInt()}%"),
//                 Expanded(
//                   child: Slider(
//                     min: 0,
//                     max: 100,
//                     value: sliderVal.value,
//                     onChanged: (index) {
//                       // sliderVal.value = index;
//                       listController?.jumpTo((totalWidth ?? 0) * index / 100);
//                     },
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                   icon: Icon(Icons.list),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class SettingPanel extends StatefulWidget {
//   const SettingPanel({super.key});

//   @override
//   State<SettingPanel> createState() => _SettingPanelState();
// }

// class _SettingPanelState extends State<SettingPanel>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Box<ReaderSettings> box;
//   late ReaderSettings setting;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//     box = Hive.box<ReaderSettings>('settings');
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     setting = box.get('defaults') ?? ReaderSettings();
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ListTile(
//           title: const Text('字体大小'),
//           subtitle: Slider(
//             value: setting.fontSize,
//             min: 12,
//             max: 32,
//             divisions: 20,
//             label: setting.fontSize.round().toString(),
//             onChanged: (double fontSize) {
//               setting.fontSize = fontSize;
//               box.put('defaults', setting);
//               setState(() {});
//             },
//           ),
//         ),
//         ListTile(
//           title: const Text('行间距'),
//           subtitle: Slider(
//             value: setting.lineHeight,
//             min: 1.0,
//             max: 3.0,
//             divisions: 20,
//             label: setting.lineHeight.toStringAsFixed(1),
//             onChanged: (double lineHeight) {
//               setting.lineHeight = lineHeight;
//               box.put('defaults', setting);
//               setState(() {});
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }




// // class SettingsPanel extends StatelessWidget {
// //   const SettingsPanel({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final state = context.watch<ReaderState>();
// //     return Selector<ReaderState, ReaderSettings>(
// //         builder: (context, settings, _) => Container(
// //               padding: EdgeInsets.only(
// //                 bottom: MediaQuery.of(context).padding.bottom,
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   ListTile(
// //                     title: const Text('字体大小'),
// //                     subtitle: Slider(
// //                       value: state.settings.fontSize,
// //                       min: 12,
// //                       max: 32,
// //                       divisions: 20,
// //                       label: state.settings.fontSize.round().toString(),
// //                       onChanged: (double fontSize) {
// //                         state.updateFontSize(fontSize);
// //                       },
// //                     ),
// //                   ),
// //                   ListTile(
// //                     title: const Text('行间距'),
// //                     subtitle: Slider(
// //                       value: state.settings.lineHeight,
// //                       min: 1.0,
// //                       max: 3.0,
// //                       divisions: 20,
// //                       label: state.settings.lineHeight.toStringAsFixed(1),
// //                       onChanged: (double lineHeight) {
// //                         state.updateLineHeight(lineHeight);
// //                       },
// //                     ),
// //                   ),
// //                   ListTile(
// //                     title: const Text('背景颜色'),
// //                     subtitle: SingleChildScrollView(
// //                       scrollDirection: Axis.horizontal,
// //                       padding: const EdgeInsets.symmetric(horizontal: 16),
// //                       child: Row(
// //                         children: [
// //                           Colors.white,
// //                           const Color(0xFFF8F3E8), // 米色
// //                           const Color(0xFFE8F3E8), // 淡绿
// //                           const Color(0xFFE8E8F3), // 淡蓝
// //                           const Color(0xFFF5E6E6), // 淡粉
// //                           const Color(0xFFE6F5F5), // 淡青
// //                           const Color(0xFFF5F5E6), // 淡黄
// //                           const Color(0xFFEEEEEE), // 浅灰
// //                           const Color(0xFFE0E0E0), // 中灰
// //                           const Color(0xFF303030), // 深色模式
// //                         ]
// //                             .map((color) => Padding(
// //                                   padding: const EdgeInsets.all(4),
// //                                   child: InkWell(
// //                                     onTap: () =>
// //                                         state.updateBackgroundColor(color),
// //                                     child: Container(
// //                                       width: 40,
// //                                       height: 40,
// //                                       decoration: BoxDecoration(
// //                                         color: color,
// //                                         border: Border.all(
// //                                           color: state.settings
// //                                                       .backgroundColorValue ==
// //                                                   color
// //                                               ? Colors.blue
// //                                               : Colors.grey,
// //                                           width: 2,
// //                                         ),
// //                                         borderRadius: BorderRadius.circular(8),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ))
// //                             .toList(),
// //                       ),
// //                     ),
// //                   ),
// //                   ListTile(
// //                     title: const Text('章节分割'),
// //                     trailing: IconButton(
// //                       icon: const Icon(Icons.edit),
// //                       onPressed: () => _showRegexDialog(context, state),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //         selector: (context, state) => state.settings);
// //   }