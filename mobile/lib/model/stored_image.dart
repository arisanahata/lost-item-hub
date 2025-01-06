import 'package:hive/hive.dart';

part 'stored_image.g.dart';

@HiveType(typeId: 1)
class StoredImage {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<int> bytes;

  @HiveField(2)
  final String fileName;

  @HiveField(3)
  final DateTime createdAt;

  const StoredImage({
    required this.id,
    required this.bytes,
    required this.fileName,
    required this.createdAt,
  });
}
