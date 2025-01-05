import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'draft_item.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
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
  final List<String>? imagePaths;

  const DraftItem({
    required this.id,
    required this.formData,
    required this.createdAt,
    required this.updatedAt,
    this.imagePaths,
  });

  DraftItem copyWith({
    String? id,
    Map<String, dynamic>? formData,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imagePaths,
  }) {
    return DraftItem(
      id: id ?? this.id,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  factory DraftItem.fromJson(Map<String, dynamic> json) =>
      _$DraftItemFromJson(json);

  Map<String, dynamic> toJson() => _$DraftItemToJson(this);
}
