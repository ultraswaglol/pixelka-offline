// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_meta_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMetaDataAdapter extends TypeAdapter<ChatMetaData> {
  @override
  final int typeId = 1;

  @override
  ChatMetaData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMetaData(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMetaData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMetaDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
