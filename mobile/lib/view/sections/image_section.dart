import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/entities/stored_image.dart';
import '../../model/repositories/local/image_repository.dart';
import '../component/section_card.dart';

class ImageSection extends HookConsumerWidget {
  final List<StoredImage>? initialImages;
  final Function(List<XFile>)? onImagesChanged;
  final Function(List<StoredImage>)? onStoredImagesChanged;

  const ImageSection({
    super.key,
    this.initialImages,
    this.onImagesChanged,
    this.onStoredImagesChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImages = useState<List<XFile>>([]); // 新しく選択された画像
    final storedImages =
        useState<List<StoredImage>>(initialImages ?? []); // 保存済みの画像
    final imageRepository = ref.watch(imageRepositoryProvider);

    // 初期画像が変更されたら更新
    useEffect(() {
      if (initialImages != null) {
        storedImages.value = initialImages!;
      }
      return null;
    }, [initialImages]);

    Future<void> pickImages() async {
      try {
        final ImagePicker picker = ImagePicker();
        final List<XFile> images = await picker.pickMultiImage(
          imageQuality: 70,
          maxWidth: 1024,
        );

        if (images.isNotEmpty) {
          for (var image in images) {
            final file = File(image.path);
            final bytes = await file.length();
            final sizeInMb = bytes / (1024 * 1024);

            if (sizeInMb > 10) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('10MB以上の画像は選択できません'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              return;
            }
          }

          final totalImages = selectedImages.value.length +
              storedImages.value.length +
              images.length;
          if (totalImages > 5) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('画像は最大5枚まで選択できます'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }

          print('ImageSection - 画像を追加:');
          print('  保存済みの画像数: ${storedImages.value.length}枚');
          print('  選択済みの画像数: ${selectedImages.value.length}枚');
          print('  追加する画像数: ${images.length}枚');

          final newImages = [...selectedImages.value, ...images];
          selectedImages.value = newImages;
          print('  更新後の画像数: ${newImages.length}枚');

          onImagesChanged?.call(newImages);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('画像を追加しました'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        print('ImageSection - 画像の選択に失敗: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('画像の選択に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    void removeStoredImage(int index) {
      print('ImageSection - 保存済みの画像を削除:');
      print('  削除する画像のインデックス: $index');
      print('  現在の画像数: ${storedImages.value.length}枚');

      final newImages = [...storedImages.value];
      newImages.removeAt(index);

      print('  更新後の画像数: ${newImages.length}枚');
      storedImages.value = newImages;
      onStoredImagesChanged?.call(newImages);
    }

    void removeSelectedImage(int index) {
      print('ImageSection - 選択済みの画像を削除:');
      print('  削除する画像のインデックス: $index');
      print('  現在の画像数: ${selectedImages.value.length}枚');

      final newImages = [...selectedImages.value];
      newImages.removeAt(index);

      print('  更新後の画像数: ${newImages.length}枚');
      selectedImages.value = newImages;
      onImagesChanged?.call(newImages);
    }

    return SectionCard(
      title: '画像',
      icon: Icons.image,
      iconColor: Colors.grey[600],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (storedImages.value.isNotEmpty ||
              selectedImages.value.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  ...storedImages.value.map((image) {
                    return FutureBuilder<StoredImage?>(
                      future: imageRepository.getImage(image.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting ||
                            !snapshot.hasData) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[100],
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            image: DecorationImage(
                              image: FileImage(File(snapshot.data!.filePath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -8,
                                right: -8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.white,
                                    iconSize: 20,
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      final newImages = [...storedImages.value];
                                      newImages.remove(image);
                                      storedImages.value = newImages;
                                      onStoredImagesChanged?.call(newImages);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                  ...selectedImages.value.map((image) {
                    return FutureBuilder<Uint8List>(
                      future: image.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          );
                        }

                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: MemoryImage(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -8,
                                right: -8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.white,
                                    iconSize: 20,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      final newImages = [
                                        ...selectedImages.value
                                      ];
                                      newImages.remove(image);
                                      selectedImages.value = newImages;
                                      onImagesChanged?.call(newImages);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: pickImages,
            icon: const Icon(Icons.add_photo_alternate,
                color: Color.fromARGB(255, 106, 106, 106)),
            label: Text(
              '画像を追加',
              style: GoogleFonts.notoSans(
                color: const Color.fromARGB(255, 106, 106, 106),
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 164, 176, 204),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
