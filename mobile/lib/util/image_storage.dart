import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../model/repositories/local/image_repository.dart';
import '../model/entities/stored_image.dart';

class ImageStorage {
  static Future<String> get basePath async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/images';
  }

  /// 画像パスから画像を保存
  static Future<List<String>> saveImagePaths(
      List<String> imagePaths, ImageRepository repository) async {
    print('ImageStorage - 画像パスから保存を開始: ${imagePaths.length}枚');
    final savedIds = <String>[];

    try {
      for (final imagePath in imagePaths) {
        final file = File(imagePath);
        if (await file.exists()) {
          final image = await repository.saveImage(file);
          savedIds.add(image.id);
          print('  画像を保存: $imagePath -> ${image.id}');
        } else {
          print('  画像が見つかりません: $imagePath');
        }
      }
    } catch (e) {
      print('  画像の保存に失敗: $e');
      rethrow;
    }

    print('ImageStorage - 保存完了: ${savedIds.length}枚');
    return savedIds;
  }

  /// 画像を保存
  static Future<StoredImage> saveImage(
    File file,
    ImageRepository repository,
  ) async {
    print('ImageStorage - 画像の保存を開始: ${file.path}');
    try {
      await repository.init(); // 明示的に初期化
      final savedImage = await repository.saveImage(file);
      print('  画像を保存: ${file.path} -> ${savedImage.id}');
      return savedImage;
    } catch (e) {
      print('  画像の保存に失敗: $e');
      rethrow;
    }
  }

  /// XFileから画像を保存
  static Future<StoredImage> saveXFile(
    XFile file,
    ImageRepository repository,
  ) async {
    print('ImageStorage - XFileから保存を開始: ${file.path}');
    try {
      final imageFile = File(file.path);
      return await saveImage(imageFile, repository);
    } catch (e) {
      print('  XFileの保存に失敗: $e');
      rethrow;
    }
  }

  /// 複数のXFileから画像を保存
  static Future<List<String>> saveXFiles(
    List<XFile> files,
    ImageRepository repository,
  ) async {
    print('ImageStorage - 複数の画像を保存:');
    print('  ファイル数: ${files.length}');

    await repository.init(); // 明示的に初期化

    final savedImageIds = <String>[];
    for (final file in files) {
      try {
        final image = await saveXFile(file, repository);
        savedImageIds.add(image.id);
        print('  画像を保存: ${image.id}');
      } catch (e) {
        print('  画像の保存に失敗: $e');
      }
    }

    print('  保存完了: ${savedImageIds.length}枚');
    return savedImageIds;
  }

  /// 複数の画像を保存
  static Future<List<String>> saveImages(
    List<XFile> files,
    ImageRepository repository,
  ) async {
    print('ImageStorage - 複数の画像を保存:');
    print('  ファイル数: ${files.length}');

    await repository.init(); // 明示的に初期化

    final savedImageIds = <String>[];
    for (final file in files) {
      try {
        final image = await saveXFile(file, repository);
        savedImageIds.add(image.id);
        print('  画像を保存: ${image.id}');
      } catch (e) {
        print('  画像の保存に失敗: $e');
      }
    }

    print('  保存完了: ${savedImageIds.length}枚');
    return savedImageIds;
  }

  /// 画像を削除
  static Future<void> deleteImages(
    List<String> ids,
    ImageRepository repository,
  ) async {
    print('ImageStorage - 画像の削除を開始: ${ids.length}枚');

    try {
      await repository.init(); // 明示的に初期化
      for (final id in ids) {
        await repository.deleteImage(id);
        print('  画像を削除: $id');
      }
    } catch (e) {
      print('  画像の削除に失敗: $e');
      rethrow;
    }
  }

  /// 画像を取得
  static Future<List<StoredImage>> getImages(
    List<String> imageIds,
    ImageRepository repository,
  ) async {
    print('ImageStorage - 画像の取得を開始: ${imageIds.length}枚');
    if (imageIds.isEmpty) {
      print('  画像IDが指定されていません');
      return [];
    }

    try {
      await repository.init(); // 明示的に初期化
      final images = <StoredImage>[];
      final invalidIds = <String>[];

      for (final id in imageIds) {
        try {
          final image = await repository.getImage(id);
          if (image != null) {
            final file = File(image.filePath);
            if (await file.exists()) {
              images.add(image);
              print('  画像を取得: $id -> ${image.filePath}');
            } else {
              print('  ファイルが存在しません: ${image.filePath}');
              invalidIds.add(id);
            }
          } else {
            print('  画像メタデータが見つかりません: $id');
            invalidIds.add(id);
          }
        } catch (e) {
          print('  画像の取得に失敗: $e');
          invalidIds.add(id);
        }
      }

      // 無効な画像を削除
      if (invalidIds.isNotEmpty) {
        print('  無効な画像を削除: ${invalidIds.length}枚');
        for (final id in invalidIds) {
          await repository.deleteImage(id);
        }
      }

      print('  取得完了: ${images.length}枚');
      return images;
    } catch (e) {
      print('  画像の取得でエラー発生: $e');
      return [];
    }
  }

  /// 画像パスをXFileに変換
  static Future<XFile> toXFile(String imagePath) async {
    final basePath = await ImageStorage.basePath;
    final absolutePath = '$basePath/$imagePath';
    final file = File(absolutePath);

    if (await file.exists()) {
      return XFile(absolutePath);
    }

    // 既に絶対パスの場合
    if (await File(imagePath).exists()) {
      return XFile(imagePath);
    }

    // それでも見つからない場合は元のパスを返す
    return XFile(absolutePath);
  }
}
