import 'dart:io';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../entities/stored_image.dart';

part 'image_repository.g.dart';

class ImageRepository {
  static const _boxName = 'images';
  late final Box<StoredImage> _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    print('ImageRepository - 初期化開始');

    // ボックスを開く
    print('  ボックスを開く');
    _box = await Hive.openBox<StoredImage>(_boxName);
    _isInitialized = true;

    print('  初期化完了');
    print('  保存済みの画像数: ${_box.length}枚');
  }

  Future<StoredImage> saveImage(File file) async {
    if (!_isInitialized) await init();

    print('ImageRepository - 画像を保存:');
    print('  ファイルパス: ${file.path}');

    // 保存先ディレクトリの取得
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');
    if (!await imagesDir.exists()) {
      print('  画像ディレクトリを作成');
      await imagesDir.create(recursive: true);
    }

    // ファイル名の生成
    final filename = path.basename(file.path);
    final storedPath = '${imagesDir.path}/$filename';

    print('  画像をコピー: $storedPath');
    // ファイルのコピー
    await file.copy(storedPath);

    // メタデータの保存
    final image = StoredImage.create(
      id: const Uuid().v4(),
      filePath: storedPath,
      fileName: filename,
      createdAt: DateTime.now(),
    );

    print('  メタデータを保存:');
    print('    ID: ${image.id}');
    print('    パス: ${image.filePath}');
    print('    名前: ${image.fileName}');
    print('    作成日時: ${image.createdAt}');

    await _box.put(image.id, image);

    print('  保存完了');
    return image;
  }

  Future<void> deleteImage(String id) async {
    if (!_isInitialized) await init();

    print('ImageRepository - 画像を削除:');
    print('  ID: $id');

    // メタデータの削除
    final image = await _box.get(id);
    if (image != null) {
      print('  メタデータを取得');
      // ファイルの削除
      final file = File(image.filePath);
      try {
        if (await file.exists()) {
          print('  ファイルを削除: ${image.filePath}');
          await file.delete();
        } else {
          print('  ファイルが既に存在しません: ${image.filePath}');
        }
      } catch (e) {
        print('  ファイルの削除に失敗: $e');
      }

      print('  メタデータを削除');
      // メタデータの削除
      await _box.delete(id);
    }

    print('  削除完了');
  }

  Future<StoredImage?> getImage(String id) async {
    if (!_isInitialized) {
      await init(); // 初期化を待つ
    }

    print('ImageRepository - 画像を取得:');
    print('  ID: $id');

    final image = _box.get(id);
    if (image == null) {
      print('  画像が見つかりません');
      return null;
    }

    // ファイルの存在確認
    final file = File(image.filePath);
    if (!file.existsSync()) {
      print('  ファイルが見つかりません: ${image.filePath}');
      return null;
    }

    print('  画像を取得:');
    print('    ID: ${image.id}');
    print('    パス: ${image.filePath}');
    print('    名前: ${image.fileName}');
    print('    作成日時: ${image.createdAt}');

    return image;
  }

  Future<List<StoredImage>> getImages() async {
    if (!_isInitialized) await init();

    print('ImageRepository - 全ての画像を取得');
    final images = _box.values.toList();
    print('  画像数: ${images.length}');

    return images;
  }
}

@Riverpod(keepAlive: true)
ImageRepository imageRepository(ImageRepositoryRef ref) {
  return ImageRepository();
}
