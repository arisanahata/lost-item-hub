import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/draft_item.dart';
import '../model/repository/item_repository.dart';
import '../model/repository/image_repository.dart';
import '../model/stored_image.dart';
import '../util/image_storage.dart';

// ドラフト一覧を監視するプロバイダー
final draftListProvider = StreamProvider<List<DraftItem>>((ref) {
  return ref.watch(itemRepositoryProvider).watchDrafts();
});

// 特定のドラフトを監視するプロバイダー
final draftProvider = StreamProvider.family<DraftItem?, String>((ref, id) {
  return ref.watch(itemRepositoryProvider).watchDraft(id);
});

// フォーム操作を管理するプロバイダー
final formViewModelProvider =
    StateNotifierProvider<FormViewModel, AsyncValue<void>>((ref) {
  return FormViewModel(
    ref.watch(itemRepositoryProvider),
    ref.watch(imageRepositoryProvider),
  );
});

class FormViewModel extends StateNotifier<AsyncValue<void>> {
  final ItemRepository _repository;
  final ImageRepository _imageRepository;

  FormViewModel(this._repository, this._imageRepository)
      : super(const AsyncValue.data(null));

  Future<void> submitForm(
      Map<String, dynamic> formData, String? draftId) async {
    try {
      state = const AsyncValue.loading();

      // TODO: APIへの送信処理
      await Future.delayed(const Duration(seconds: 1));

      // 送信成功後、下書きを削除
      if (draftId != null) {
        await _repository.deleteDraft(draftId);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      print('FormViewModel - 送信エラー: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveDraft(Map<String, dynamic> formData, List<String> imagePaths,
      {String? draftId}) async {
    try {
      state = const AsyncValue.loading();
      print('FormViewModel - 下書き保存を開始');

      // 画像の保存処理
      final List<String> savedImageIds = [];
      if (imagePaths.isNotEmpty) {
        print('  画像データを処理: ${imagePaths.length}枚');
        
        for (var path in imagePaths) {
          // 既存の画像IDの場合はそのまま追加
          if (!path.startsWith('/')) {
            savedImageIds.add(path);
            print('  既存の画像を追加: $path');
            continue;
          }

          // 新しい画像の場合はファイルを保存
          final file = File(path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final fileName = path.split('/').last;
            final savedImage = await _imageRepository.saveImage(bytes, fileName);
            savedImageIds.add(savedImage.id);
            print('  新しい画像を保存: ${savedImage.id}');
          } else {
            print('  画像ファイルが存在しません: $path');
          }
        }
      }

      // 既存のドラフトを取得（更新の場合）
      DateTime createdAt = DateTime.now();
      if (draftId != null) {
        final existingDraft = await _repository.getDraft(draftId);
        if (existingDraft != null) {
          createdAt = existingDraft.createdAt;
          // 既存の画像を削除（新しい画像で上書き）
          if (existingDraft.imagePaths != null) {
            final imagesToDelete = existingDraft.imagePaths!
                .where((id) => !savedImageIds.contains(id))
                .toList();
            if (imagesToDelete.isNotEmpty) {
              print('  不要な画像を削除: ${imagesToDelete.length}枚');
              await _imageRepository.deleteImages(imagesToDelete);
            }
          }
        }
      }

      final draft = DraftItem(
        id: draftId ?? const Uuid().v4(),
        formData: formData,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        imagePaths: savedImageIds,
      );

      print('  下書きを保存:');
      print('    ID: ${draft.id}');
      print('    画像数: ${savedImageIds.length}枚');
      print('    画像ID: $savedImageIds');

      await _repository.saveDraft(draft);
      print('  下書き保存完了');

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      print('FormViewModel - 下書き保存エラー:');
      print('  エラー: $e');
      print('  スタックトレース: $stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateDraft(String id, Map<String, dynamic> formData) async {
    try {
      state = const AsyncValue.loading();
      print('FormViewModel - 下書き更新を開始: $id');

      // 既存のドラフトを取得
      final existingDraft = await _repository.getDraft(id);
      if (existingDraft == null) throw Exception('Draft not found');

      // 既存の画像を削除
      if (existingDraft.imagePaths != null) {
        print('  既存の画像を削除: ${existingDraft.imagePaths!.length}枚');
        await _imageRepository.deleteImages(existingDraft.imagePaths!);
      }

      // 新しい画像を保存
      final imagePaths = formData['images'] as List<String>?;
      print('  新しい画像を処理: ${imagePaths?.length ?? 0}枚');

      List<String>? savedImageIds;
      if (imagePaths != null && imagePaths.isNotEmpty) {
        print('  画像を保存');
        savedImageIds = [];
        for (var path in imagePaths) {
          // 既存の画像IDの場合はそのまま追加
          if (!path.startsWith('/')) {
            savedImageIds.add(path);
            print('  既存の画像を追加: $path');
            continue;
          }

          // 新しい画像の場合はファイルを保存
          final file = File(path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final fileName = path.split('/').last;
            final savedImage =
                await _imageRepository.saveImage(bytes, fileName);
            savedImageIds.add(savedImage.id);
            print('  新しい画像を保存: ${savedImage.id}');
          } else {
            print('  画像ファイルが存在しません: $path');
          }
        }
      }

      // フォームデータから画像を削除
      formData.remove('images');

      // ドラフトを更新
      final updatedDraft = DraftItem(
        id: id,
        formData: formData,
        createdAt: existingDraft.createdAt,
        updatedAt: DateTime.now(),
        imagePaths: savedImageIds,
      );

      print('  下書きを更新:');
      print('    画像数: ${savedImageIds?.length ?? 0}枚');

      await _repository.updateDraft(id, updatedDraft);
      state = const AsyncValue.data(null);
      print('  下書き更新完了');
    } catch (e, stack) {
      print('FormViewModel - 下書き更新エラー: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteDraft(String id) async {
    try {
      state = const AsyncValue.loading();

      // ドラフトの画像を削除
      final draft = await _repository.getDraft(id);
      if (draft?.imagePaths != null) {
        print('  画像を削除: ${draft!.imagePaths!.length}枚');
        await _imageRepository.deleteImages(draft.imagePaths!);
      }

      await _repository.deleteDraft(id);
      state = const AsyncValue.data(null);
      print('  下書き削除完了');
    } catch (e, stack) {
      print('FormViewModel - 下書き削除エラー: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  // 画像の追加
  Future<List<String>> addImages(
      List<String> newImagePaths, List<String>? existingImagePaths) async {
    try {
      List<String> allImageIds = [...(existingImagePaths ?? [])];

      for (var path in newImagePaths) {
        // 既存の画像IDの場合はスキップ
        if (!path.startsWith('/')) continue;

        // 新しい画像の場合はファイルを保存
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final fileName = path.split('/').last;
          final savedImage = await _imageRepository.saveImage(bytes, fileName);
          allImageIds.add(savedImage.id);
          print('  新しい画像を保存: ${savedImage.id}');
        } else {
          print('  画像ファイルが存在しません: $path');
        }
      }

      return allImageIds;
    } catch (e) {
      print('FormViewModel - 画像追加エラー: $e');
      rethrow;
    }
  }

  // 画像の削除
  Future<List<String>> removeImage(
      String imageId, List<String> currentImageIds) async {
    try {
      final newImageIds = List<String>.from(currentImageIds);
      newImageIds.remove(imageId);

      // 画像ファイルの削除
      await _imageRepository.deleteImage(imageId);
      print('  画像を削除: $imageId');

      return newImageIds;
    } catch (e) {
      print('FormViewModel - 画像削除エラー: $e');
      rethrow;
    }
  }

  Future<List<StoredImage>> loadImages(List<String> imageIds) async {
    print('FormViewModel - 画像読み込みを開始:');
    print('  読み込む画像ID: $imageIds');
    
    try {
      final loadedImages = <StoredImage>[];
      for (var id in imageIds) {
        // ファイルパスの場合はスキップ
        if (id.startsWith('/')) {
          print('  無効な画像ID (ファイルパス): $id');
          continue;
        }
        
        print('  画像を読み込み中: $id');
        final image = await _imageRepository.getImage(id);
        if (image != null) {
          loadedImages.add(image);
          print('    読み込み成功: ${image.id} (${image.bytes.length} bytes)');
        } else {
          print('    読み込み失敗: $id');
        }
      }
      print('  読み込み完了: ${loadedImages.length}枚の画像を読み込みました');
      return loadedImages;
    } catch (e, stack) {
      print('FormViewModel - 画像読み込みエラー:');
      print('  エラー: $e');
      print('  スタックトレース: $stack');
      return [];
    }
  }
}
