// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftItemAdapter extends TypeAdapter<DraftItem> {
  @override
  final int typeId = 0;

  @override
  DraftItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DraftItem(
      id: fields[0] as String,
      formData: (fields[1] as Map).cast<String, dynamic>(),
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      imagePaths: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DraftItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.formData)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.imagePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftItem _$DraftItemFromJson(Map<String, dynamic> json) => DraftItem(
      id: json['id'] as String,
      formData: json['formData'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imagePaths: (json['imagePaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DraftItemToJson(DraftItem instance) => <String, dynamic>{
      'id': instance.id,
      'formData': instance.formData,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'imagePaths': instance.imagePaths,
    };
