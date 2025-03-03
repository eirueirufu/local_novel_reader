// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      title: fields[0] as String,
    )
      ..lastReadChapterIndex = fields[1] as int
      ..lastReadPosition = fields[2] as int
      ..lastReadTime = fields[3] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.lastReadChapterIndex)
      ..writeByte(2)
      ..write(obj.lastReadPosition)
      ..writeByte(3)
      ..write(obj.lastReadTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
