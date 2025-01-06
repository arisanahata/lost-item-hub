// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredImageAdapter extends TypeAdapter<StoredImage> {
  @override
  final int typeId = 1;

  @override
  StoredImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredImage(
      id: fields[0] as String,
      bytes: (fields[1] as List).cast<int>(),
      fileName: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StoredImage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bytes)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
