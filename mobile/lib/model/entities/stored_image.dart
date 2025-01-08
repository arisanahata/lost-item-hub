import 'package:hive/hive.dart';

part 'stored_image.g.dart';

@HiveType(typeId: 2)
class StoredImage {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final String fileName;

  @HiveField(3)
  final int createdAtMillis;

  StoredImage({
    required this.id,
    required this.filePath,
    required this.fileName,
    this.createdAtMillis = 0,
  });

  factory StoredImage.create({
    required String id,
    required String filePath,
    required String fileName,
    required DateTime createdAt,
  }) {
    return StoredImage(
      id: id,
      filePath: filePath,
      fileName: fileName,
      createdAtMillis: createdAt.millisecondsSinceEpoch,
    );
  }

  String get path => filePath;
  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtMillis);
}
