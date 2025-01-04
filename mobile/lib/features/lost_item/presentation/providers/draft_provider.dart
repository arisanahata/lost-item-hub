import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/draft_item.dart';

const _draftBoxName = 'drafts';

final draftListProvider =
    AsyncNotifierProvider<DraftNotifier, List<DraftItem>>(() {
  return DraftNotifier();
});

class DraftNotifier extends AsyncNotifier<List<DraftItem>> {
  late Box<DraftItem> _draftsBox;

  @override
  Future<List<DraftItem>> build() async {
    await _initHive();
    return _loadDrafts();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_draftBoxName)) {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DraftItemAdapter());
      }
      _draftsBox = await Hive.openBox<DraftItem>(_draftBoxName);
    } else {
      _draftsBox = Hive.box<DraftItem>(_draftBoxName);
    }
  }

  List<DraftItem> _loadDrafts() {
    return _draftsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveDraft(Map<String, dynamic> formData, {String? draftId}) async {
    final now = DateTime.now();
    final draft = DraftItem(
      id: draftId ?? const Uuid().v4(),
      formData: formData,
      createdAt: now,
      updatedAt: now,
    );

    await _draftsBox.put(draft.id, draft);
    state = AsyncData(_loadDrafts());
  }

  Future<void> deleteDraft(String id) async {
    await _draftsBox.delete(id);
    state = AsyncData(_loadDrafts());
  }

  Future<void> deleteAllDrafts() async {
    await _draftsBox.clear();
    state = AsyncData(_loadDrafts());
  }

  DraftItem? getDraft(String id) {
    return _draftsBox.get(id);
  }
}
