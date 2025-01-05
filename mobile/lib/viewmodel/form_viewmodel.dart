import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/draft_item.dart';
import '../model/lost_item.dart';
import '../model/repository/item_repository.dart';

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

  Future<void> submitForm(Map<String, dynamic> formData, String? draftId) async {
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

      final draft = DraftItem(
        id: const Uuid().v4(),
        formData: Map<String, dynamic>.from(formData),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
      if (existingDraft == null) {
        throw Exception('ドラフトが見つかりません: $id');
      }

      // 既存のドラフトの情報を保持しつつ更新
      final draft = existingDraft.copyWith(
        formData: Map<String, dynamic>.from(formData),
        updatedAt: DateTime.now(),
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
      await _repository.deleteDraft(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
