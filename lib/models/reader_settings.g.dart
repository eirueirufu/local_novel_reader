// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReaderSettingsAdapter extends TypeAdapter<ReaderSettings> {
  @override
  final int typeId = 1;

  @override
  ReaderSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReaderSettings(
      fontSize: fields[0] as double,
      lineHeight: fields[2] as double,
      backgroundColor: fields[1] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, ReaderSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.fontSize)
      ..writeByte(1)
      ..write(obj.backgroundColor)
      ..writeByte(2)
      ..write(obj.lineHeight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
