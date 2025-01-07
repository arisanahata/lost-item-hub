import 'dart:io';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../entities/stored_image.dart';

part 'image_repository.g.dart';

class ImageRepository {
  static const _boxName = 'images';
  late final Box<StoredImage> _box;
  late final Directory _imageDir;

  Future<void> init() async {
    _box = await Hive.openBox<StoredImage>(_boxName);
    final appDir = await getApplicationDocumentsDirectory();
    _imageDir = Directory(path.join(appDir.path, 'images'));
    if (!await _imageDir.exists()) {
      await _imageDir.create(recursive: true);
    }
  }

  // 画像の保存
  Future<StoredImage> saveImage(File file) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final fileName = '$id${path.extension(file.path)}';
    final savedFile = await file.copy(path.join(_imageDir.path, fileName));

    final image = StoredImage(
      id: id,
      filePath: savedFile.path,
      createdAt: DateTime.now(),
    );

    await _box.put(id, image);
    return image;
  }

  // 画像の削除
  Future<void> deleteImage(String id) async {
    final image = _box.get(id);
    if (image != null) {
      final file = File(image.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _box.delete(id);
    }
  }

  // 画像の取得
  Future<StoredImage?> getImage(String id) async {
    return _box.get(id);
  }

  // 画像一覧の取得
  Future<List<StoredImage>> getAllImages() async {
    return _box.values.toList();
  }
}

@riverpod
ImageRepository imageRepository(ImageRepositoryRef ref) {
  return ImageRepository();
}
