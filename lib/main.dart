import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/bookshelf_page.dart';
import 'models/book.dart';
import 'models/reader_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(ReaderSettingsAdapter());

  await Hive.openBox<Book>('books');
  await Hive.openBox<ReaderSettings>('settings');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '本地小说阅读器',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: ValueListenableBuilder(
        valueListenable: Hive.box<Book>('books').listenable(),
        builder: (context, box, _) => BookShelfPage(),
      ),
    );
  }
}
