import 'dart:async';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../entities/draft_item.dart';

part 'item_repository.g.dart';

class ItemRepository {
  static const _boxName = 'drafts';
  late final Box<DraftItem> _box;

  Future<void> init() async {
    _box = await Hive.openBox<DraftItem>(_boxName);
  }

  // ドラフトの保存
  Future<void> saveDraft(DraftItem draft) async {
    await _box.put(draft.id, draft);
  }

  // ドラフトの削除
  Future<void> deleteDraft(String id) async {
    await _box.delete(id);
  }

  // ドラフト一覧の取得（Stream）
  Stream<List<DraftItem>> watchDrafts() async* {
    // 初期データを返す
    yield _box.values.toList();

    // 変更を監視して返す
    await for (final _ in _box.watch()) {
      yield _box.values.toList();
    }
  }

  // ドラフトの取得
  DraftItem? getDraft(String id) {
    return _box.get(id);
  }
}

@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return ItemRepository();
}
