import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reader_settings.g.dart';

@HiveType(typeId: 1)
class ReaderSettings {
  @HiveField(0)
  double fontSize;

  @HiveField(1)
  int backgroundColor;

  @HiveField(2)
  double lineHeight;

  ReaderSettings({
    this.fontSize = 18,
    this.lineHeight = 1.5,
    Color backgroundColor = Colors.white,
  }) : backgroundColor = backgroundColor.value;

  Color get backgroundColorValue => Color(backgroundColor);
  set backgroundColorValue(Color color) => backgroundColor = color.value;
}
