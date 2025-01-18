// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chapters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookChaptersAdapter extends TypeAdapter<BookChapters> {
  @override
  final int typeId = 3;

  @override
  BookChapters read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookChapters(
      content: fields[1] as String,
    )..chapters = (fields[2] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, BookChapters obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookChaptersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
