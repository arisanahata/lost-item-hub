import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'stored_image.dart';

part 'draft_item.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class DraftItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, dynamic> formData;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final List<String>? imageIds;

  @JsonKey(ignore: true) // HiveFieldを削除
  final List<StoredImage>? storedImages;

  const DraftItem({
    required this.id,
    required this.formData,
    required this.createdAt,
    required this.updatedAt,
    this.imageIds,
    this.storedImages,
  });

  DraftItem copyWith({
    String? id,
    Map<String, dynamic>? formData,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imageIds,
    List<StoredImage>? storedImages,
  }) {
    return DraftItem(
      id: id ?? this.id,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageIds: imageIds ?? this.imageIds,
      storedImages: storedImages ?? this.storedImages,
    );
  }

  factory DraftItem.fromJson(Map<String, dynamic> json) =>
      _$DraftItemFromJson(json);

  Map<String, dynamic> toJson() => _$DraftItemToJson(this);
}
