import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../stored_image.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepository();
});

class ImageRepository {
  static const _imageBoxName = 'images';
  late Box<StoredImage> _imagesBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_imageBoxName)) {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(StoredImageAdapter());
      }
      _imagesBox = await Hive.openBox<StoredImage>(_imageBoxName);
    } else {
      _imagesBox = Hive.box<StoredImage>(_imageBoxName);
    }
  }

  Future<StoredImage> saveImage(List<int> bytes, String fileName) async {
    await init();
    
    final image = StoredImage(
      id: const Uuid().v4(),
      bytes: bytes,
      fileName: fileName,
      createdAt: DateTime.now(),
    );
    
    await _imagesBox.put(image.id, image);
    return image;
  }

  Future<StoredImage?> getImage(String id) async {
    await init();
    return _imagesBox.get(id);
  }

  Future<List<StoredImage>> getImages(List<String> ids) async {
    await init();
    return ids.map((id) => _imagesBox.get(id)).whereType<StoredImage>().toList();
  }

  Future<void> deleteImage(String id) async {
    await init();
    await _imagesBox.delete(id);
  }

  Future<void> deleteImages(List<String> ids) async {
    await init();
    await Future.wait(ids.map((id) => _imagesBox.delete(id)));
  }
}
