import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/bookshelf_page.dart';
import 'models/book.dart';
import 'models/reader_settings.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 注册适配器
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(ReaderSettingsAdapter());

  // 清理所有数据
  await Hive.deleteBoxFromDisk('books');
  await Hive.deleteBoxFromDisk('settings');

  // 打开盒子
  await Hive.openBox<Book>('books');
  await Hive.openBox<ReaderSettings>('settings');

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小说阅读器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BookshelfPage(),
    );
  }
}
