import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../model/draft_item.dart';
import '../model/lost_item.dart';
import '../model/repository/item_repository.dart';
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
  return FormViewModel(ref.watch(itemRepositoryProvider));
});

class FormViewModel extends StateNotifier<AsyncValue<void>> {
  final ItemRepository _repository;

  FormViewModel(this._repository) : super(const AsyncValue.data(null));

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
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveDraft(Map<String, dynamic> formData) async {
    try {
      state = const AsyncValue.loading();

      // 画像を保存
      final images = formData['images'] as List<XFile>?;
      List<String>? savedImagePaths;
      if (images != null && images.isNotEmpty) {
        savedImagePaths = await ImageStorage.saveImages(images);
      }

      // フォームデータから画像を削除
      formData.remove('images');

      final draft = DraftItem(
        id: const Uuid().v4(),
        formData: formData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imagePaths: savedImagePaths,
      );

      await _repository.saveDraft(draft);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateDraft(String id, Map<String, dynamic> formData) async {
    try {
      state = const AsyncValue.loading();

      // 既存のドラフトを取得
      final existingDraft = await _repository.getDraft(id);
      if (existingDraft == null) throw Exception('Draft not found');

      // 既存の画像を削除
      if (existingDraft.imagePaths != null) {
        await ImageStorage.deleteImages(existingDraft.imagePaths!);
      }

      // 新しい画像を保存
      final images = formData['images'] as List<XFile>?;
      List<String>? savedImagePaths;
      if (images != null && images.isNotEmpty) {
        savedImagePaths = await ImageStorage.saveImages(images);
      }

      // フォームデータから画像を削除
      formData.remove('images');

      // ドラフトを更新
      final draft = existingDraft.copyWith(
        formData: formData,
        updatedAt: DateTime.now(),
        imagePaths: savedImagePaths,
      );

      await _repository.updateDraft(id, draft);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteDraft(String id) async {
    try {
      state = const AsyncValue.loading();

      // ドラフトの画像を削除
      final draft = await _repository.getDraft(id);
      if (draft?.imagePaths != null) {
        await ImageStorage.deleteImages(draft!.imagePaths!);
      }

      await _repository.deleteDraft(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
