// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredImageAdapter extends TypeAdapter<StoredImage> {
  @override
  final int typeId = 2;

  @override
  StoredImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredImage(
      id: fields[0] as String,
      filePath: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StoredImage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoredImageImpl _$$StoredImageImplFromJson(Map<String, dynamic> json) =>
    _$StoredImageImpl(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StoredImageImplToJson(_$StoredImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filePath': instance.filePath,
      'createdAt': instance.createdAt.toIso8601String(),
    };
