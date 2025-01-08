import 'dart:async';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../entities/draft_item.dart';
import '../api/item_repository.dart';
import '../../../util/image_storage.dart';
import '../local/image_repository.dart';
part 'item_repository.g.dart';

class ItemRepository {
  static const _boxName = 'drafts';
  late final Box<DraftItem> _box;
  final ItemApiRepository _apiRepository;
  final ImageRepository _imageRepository;

  ItemRepository(this._apiRepository, this._imageRepository);

  Future<void> init() async {
    _box = await Hive.openBox<DraftItem>(_boxName);
  }

  // ドラフトの保存
  Future<void> saveDraft(DraftItem draft) async {
    await _box.put(draft.id, draft);
  }

  // ドラフトの削除
  Future<void> deleteDraft(String id) async {
    // 下書きに関連する画像IDを取得
    final draft = _box.get(id);
    if (draft?.imageIds != null && draft!.imageIds!.isNotEmpty) {
      print('  関連する画像を削除: ${draft.imageIds!.length}枚');
      await ImageStorage.deleteImages(
        draft.imageIds!,
        _imageRepository,
      );
    }
    await _box.delete(id);
  }

  // ドラフト一覧の取得
  List<DraftItem> getDrafts() {
    return _box.values.toList();
  }

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

  Future<void> submit(
      Map<String, dynamic> formData, List<String> imageIds) async {
    print('ItemRepository - フォームを送信:');
    print('  フォームデータ: $formData');
    print('  画像ID: ${imageIds.length}枚');

    try {
      // APIに送信
      await _apiRepository.submit(formData, imageIds);
      print('  送信完了');
    } catch (e) {
      print('  送信エラー: $e');
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
ItemRepository itemRepository(ItemRepositoryRef ref) {
  final apiRepository = ref.watch(itemApiRepositoryProvider);
  final imageRepository = ref.watch(imageRepositoryProvider);
  return ItemRepository(apiRepository, imageRepository);
}
