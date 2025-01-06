import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../model/repository/image_repository.dart';
import '../model/stored_image.dart';

class ImageStorage {
  static Future<String> get basePath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/images';
    await Directory(path).create(recursive: true);
    return path;
  }

  /// 画像パスから画像を保存
  static Future<List<String>> saveImagePaths(List<String> imagePaths, ImageRepository repository) async {
    print('ImageStorage - 画像パスから保存を開始: ${imagePaths.length}枚');
    final savedIds = <String>[];

    for (var path in imagePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final fileName = path.split('/').last;
          final savedImage = await repository.saveImage(bytes, fileName);
          savedIds.add(savedImage.id);
          print('  画像を保存: ${savedImage.id}');
        } else {
          print('  画像ファイルが存在しません: $path');
        }
      } catch (e) {
        print('  画像の保存に失敗: $e');
      }
    }

    print('ImageStorage - 保存完了: ${savedIds.length}枚');
    return savedIds;
  }

  /// 画像を保存
  static Future<List<String>> saveImages(List<XFile> images, ImageRepository repository) async {
    print('ImageStorage - 画像の保存を開始: ${images.length}枚');
    final savedIds = <String>[];

    for (var image in images) {
      try {
        final bytes = await image.readAsBytes();
        final fileName = image.name;
        final savedImage = await repository.saveImage(bytes, fileName);
        savedIds.add(savedImage.id);
        print('  画像を保存: ${savedImage.id}');
      } catch (e) {
        print('  画像の保存に失敗: $e');
      }
    }

    print('ImageStorage - 保存完了: ${savedIds.length}枚');
    return savedIds;
  }

  /// 画像を削除
  static Future<void> deleteImages(List<String> ids, ImageRepository repository) async {
    print('ImageStorage - 画像の削除を開始: ${ids.length}枚');
    
    try {
      await repository.deleteImages(ids);
      print('  画像を削除: ${ids.length}枚');
    } catch (e) {
      print('  画像の削除に失敗: $e');
    }
    
    print('ImageStorage - 削除完了');
  }

  /// 画像を取得
  static Future<List<StoredImage>> getImages(List<String> ids, ImageRepository repository) async {
    print('ImageStorage - 画像の取得を開始: ${ids.length}枚');
    
    try {
      final images = await repository.getImages(ids);
      print('  画像を取得: ${images.length}枚');
      return images;
    } catch (e) {
      print('  画像の取得に失敗: $e');
      return [];
    }
  }

  static Future<String> getAbsolutePath(String relativePath) async {
    final basePath = await ImageStorage.basePath;
    return '$basePath/$relativePath';
  }

  static Future<XFile> pathToXFile(String imagePath) async {
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

  static Future<List<XFile>> pathsToXFiles(List<String> imagePaths) async {
    final xFiles = <XFile>[];
    for (final path in imagePaths) {
      xFiles.add(await pathToXFile(path));
    }
    return xFiles;
  }
}
