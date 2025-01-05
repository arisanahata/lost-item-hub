import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../draft_item.dart';
import '../lost_item.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

class ItemRepository {
  static const _draftBoxName = 'drafts';
  late Box<DraftItem> _draftsBox;

  // TODO: APIクライアントの注入

  Future<void> init() async {
    if (!Hive.isBoxOpen(_draftBoxName)) {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DraftItemAdapter());
      }
      _draftsBox = await Hive.openBox<DraftItem>(_draftBoxName);
    } else {
      _draftsBox = Hive.box<DraftItem>(_draftBoxName);
    }
  }

  // Lost Item operations
  Future<void> saveLostItem(LostItem item) async {
    // TODO: APIへの送信処理
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<LostItem>> getItems() async {
    // TODO: APIからの一覧取得
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  Future<LostItem?> getItem(String id) async {
    // TODO: APIからの取得
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  // Draft operations
  Future<List<DraftItem>> getDrafts() async {
    await init();
    return _draftsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<DraftItem?> getDraft(String id) async {
    await init();
    return _draftsBox.get(id);
  }

  Future<void> saveDraft(DraftItem draft) async {
    await init();
    await _draftsBox.put(draft.id, draft);
  }

  Future<void> updateDraft(String id, DraftItem draft) async {
    await init();
    await _draftsBox.put(id, draft);
  }

  Future<void> deleteDraft(String id) async {
    await init();
    await _draftsBox.delete(id);
  }

  Future<void> deleteAllDrafts() async {
    await init();
    await _draftsBox.clear();
  }

  // Watch operations
  Stream<List<DraftItem>> watchDrafts() async* {
    await init();
    yield await getDrafts();

    await for (final _ in _draftsBox.watch()) {
      yield await getDrafts();
    }
  }

  Stream<DraftItem?> watchDraft(String id) async* {
    await init();
    yield await getDraft(id);

    await for (final event in _draftsBox.watch()) {
      if (event.key == id) {
        yield await getDraft(id);
      }
    }
  }

  Stream<List<LostItem>> watchItems() async* {
    // TODO: APIからのリアルタイム監視
    yield await getItems();
    await for (final _ in Stream.periodic(const Duration(seconds: 10))) {
      yield await getItems();
    }
  }

  Stream<LostItem?> watchItem(String id) async* {
    // TODO: APIからのリアルタイム監視
    yield await getItem(id);
    await for (final _ in Stream.periodic(const Duration(seconds: 10))) {
      yield await getItem(id);
    }
  }
}
