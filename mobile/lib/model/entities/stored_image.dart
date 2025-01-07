import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'stored_image.freezed.dart';
part 'stored_image.g.dart';

@freezed
@HiveType(typeId: 2)
class StoredImage with _$StoredImage {
  const factory StoredImage({
    @HiveField(0)
    required String id,
    
    @HiveField(1)
    required String filePath,
    
    @HiveField(2)
    required DateTime createdAt,
  }) = _StoredImage;

  factory StoredImage.fromJson(Map<String, dynamic> json) =>
      _$StoredImageFromJson(json);
}
