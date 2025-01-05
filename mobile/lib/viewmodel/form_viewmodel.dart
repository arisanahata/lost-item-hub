import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/draft_item.dart';
import '../model/lost_item.dart';
import '../model/repository/item_repository.dart';

final formViewModelProvider =
    StateNotifierProvider<FormViewModel, AsyncValue<void>>((ref) {
  return FormViewModel(ref.watch(itemRepositoryProvider));
});

final formDataProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {};
});

final draftListProvider =
    AsyncNotifierProvider<DraftNotifier, List<DraftItem>>(DraftNotifier.new);

class DraftNotifier extends AsyncNotifier<List<DraftItem>> {
  @override
  Future<List<DraftItem>> build() async {
    return ref.watch(itemRepositoryProvider).getDrafts();
  }

  Future<void> saveDraft(Map<String, dynamic> formData) async {
    final draft = DraftItem(
      id: const Uuid().v4(),
      formData: formData,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(itemRepositoryProvider).saveDraft(draft);
    state = AsyncData(await ref.read(itemRepositoryProvider).getDrafts());
  }

  Future<void> updateDraft(String id, Map<String, dynamic> formData) async {
    final draft = DraftItem(
      id: id,
      formData: formData,
      createdAt: DateTime.now(), // TODO: 既存の作成日時を保持する
      updatedAt: DateTime.now(),
    );

    await ref.read(itemRepositoryProvider).updateDraft(id, draft);
    state = AsyncData(await ref.read(itemRepositoryProvider).getDrafts());
  }

  Future<void> deleteDraft(String id) async {
    await ref.read(itemRepositoryProvider).deleteDraft(id);
    state = AsyncData(await ref.read(itemRepositoryProvider).getDrafts());
  }
}

final draftProvider = StreamProvider.family<DraftItem?, String>((ref, id) {
  return ref.watch(itemRepositoryProvider).watchDraft(id);
});

class FormViewModel extends StateNotifier<AsyncValue<void>> {
  final ItemRepository _repository;

  FormViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> submitForm(
      Map<String, dynamic> formData, String? draftId) async {
    try {
      state = const AsyncValue.loading();

      final item = LostItem.fromFormData(formData);
      await _repository.saveLostItem(item);

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
        formData: formData,
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

      final draft = DraftItem(
        id: id,
        formData: formData,
        createdAt: DateTime.now(), // TODO: 既存の作成日時を保持する
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
