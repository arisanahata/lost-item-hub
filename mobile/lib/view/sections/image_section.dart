import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../component/section_card.dart';

class ImageSection extends HookWidget {
  final List<XFile>? initialImages;
  final Function(List<XFile>)? onImagesChanged;

  const ImageSection({
    super.key,
    this.initialImages,
    this.onImagesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedImages = useState<List<XFile>>(initialImages ?? []);

    Future<void> pickImages() async {
      try {
        final ImagePicker picker = ImagePicker();
        final List<XFile> images = await picker.pickMultiImage(
          imageQuality: 70, // 画質を70%に圧縮
          maxWidth: 1024, // 最大幅を1024pxに制限
        );

        if (images.isNotEmpty) {
          // 選択された画像のサイズをチェック
          for (var image in images) {
            final file = File(image.path);
            final bytes = await file.length();
            final sizeInMb = bytes / (1024 * 1024);

            if (sizeInMb > 10) {
              // 10MB以上の場合は警告
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

          final newImages = [...selectedImages.value, ...images];
          if (newImages.length > 5) {
            // 最大5枚まで
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

          selectedImages.value = newImages;
          onImagesChanged?.call(newImages);

          // 成功メッセージを表示
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

    void removeImage(int index) {
      final newImages = [...selectedImages.value];
      newImages.removeAt(index);
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
          if (selectedImages.value.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedImages.value.map((image) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(image.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
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
                          onPressed: () => removeImage(
                            selectedImages.value.indexOf(image),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
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
