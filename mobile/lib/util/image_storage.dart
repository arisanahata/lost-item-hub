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
  static Future<List<String>> saveImages(
      List<XFile> images, ImageRepository repository) async {
    print('ImageStorage - 画像の保存を開始: ${images.length}枚');
    final savedIds = <String>[];

    try {
      for (final image in images) {
        final file = File(image.path);
        final savedImage = await repository.saveImage(file);
        savedIds.add(savedImage.id);
        print('  画像を保存: ${image.path} -> ${savedImage.id}');
      }
    } catch (e) {
      print('  画像の保存に失敗: $e');
      rethrow;
    }

    print('ImageStorage - 保存完了: ${savedIds.length}枚');
    return savedIds;
  }

  /// 画像を削除
  static Future<void> deleteImages(
      List<String> ids, ImageRepository repository) async {
    print('ImageStorage - 画像の削除を開始: ${ids.length}枚');

    try {
      for (final id in ids) {
        await repository.deleteImage(id);
      }
      print('  画像を削除: ${ids.length}枚');
    } catch (e) {
      print('  画像の削除に失敗: $e');
      rethrow;
    }

    print('ImageStorage - 削除完了');
  }

  /// 画像を取得
  static Future<List<StoredImage>> getImages(
      List<String> ids, ImageRepository repository) async {
    print('ImageStorage - 画像の取得を開始: ${ids.length}枚');

    try {
      final images = <StoredImage>[];
      for (final id in ids) {
        final image = await repository.getImage(id);
        if (image != null) {
          images.add(image);
        }
      }
      print('  画像を取得: ${images.length}枚');
      return images;
    } catch (e) {
      print('  画像の取得に失敗: $e');
      rethrow;
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
