import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class ImageStorage {
  static String? _basePath;
  static const String _imageDir = 'images';

  static Future<String> get basePath async {
    if (_basePath == null) {
      final directory = await getApplicationDocumentsDirectory();
      _basePath = directory.path;
      
      // 画像保存用ディレクトリがない場合は作成
      final imageDir = Directory('$_basePath/$_imageDir');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
    }
    return _basePath!;
  }

  static Future<String> saveImage(XFile image) async {
    final basePath = await ImageStorage.basePath;
    
    // ユニークなファイル名を生成
    final extension = path.extension(image.path);
    final fileName = '${const Uuid().v4()}$extension';
    final relativePath = '$_imageDir/$fileName';
    final absolutePath = '$basePath/$relativePath';

    // 画像をコピー
    final File newImage = File(absolutePath);
    await newImage.writeAsBytes(await image.readAsBytes());

    // 相対パスを返す
    return relativePath;
  }

  static Future<List<String>> saveImages(List<XFile> images) async {
    final savedPaths = <String>[];
    for (final image in images) {
      final savedPath = await saveImage(image);
      savedPaths.add(savedPath);
    }
    return savedPaths;
  }

  static Future<void> deleteImage(String imagePath) async {
    final basePath = await ImageStorage.basePath;
    final absolutePath = '$basePath/$imagePath';
    final file = File(absolutePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteImages(List<String> imagePaths) async {
    for (final path in imagePaths) {
      await deleteImage(path);
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
