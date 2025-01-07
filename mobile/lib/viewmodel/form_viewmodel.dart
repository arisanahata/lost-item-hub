import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/entities/draft_item.dart';
import '../model/repositories/api/item_repository.dart';
import '../model/repositories/local/item_repository.dart';
import '../model/repositories/local/image_repository.dart';
import '../model/entities/stored_image.dart';
import '../util/image_storage.dart';

// ドラフト一覧を監視するプロバイダー
final draftListProvider = StreamProvider<List<DraftItem>>((ref) {
  return ref.watch(itemRepositoryProvider).watchDrafts();
});

// 特定のドラフトを監視するプロバイダー
final draftProvider = StreamProvider.family<DraftItem?, String>((ref, id) {
  final draft = ref.watch(itemRepositoryProvider).getDraft(id);
  return Stream.value(draft);
});

// フォーム操作を管理するプロバイダー
final formViewModelProvider =
    StateNotifierProvider<FormViewModel, AsyncValue<void>>((ref) {
  return FormViewModel(ref);
});

class FormViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  late final ItemRepository _repository;
  late final ImageRepository _imageRepository;
  late final ItemApiRepository _apiRepository;

  FormViewModel(this.ref) : super(const AsyncValue.data(null)) {
    _repository = ref.read(itemRepositoryProvider);
    _imageRepository = ref.read(imageRepositoryProvider);
    _apiRepository = ref.read(itemApiRepositoryProvider);

    print('\nFormViewModel - 初期化:');
    print('  APIリポジトリ: $_apiRepository');
    print('  APIリポジトリのbaseUrl: ${_apiRepository.baseUrl}');
  }

  Future<void> submitForm(Map<String, dynamic> formData, List<String> imageIds,
      {String? draftId}) async {
    try {
      state = const AsyncValue.loading();
      print('FormViewModel - フォーム送信を開始');

      // 画像の保存処理
      final List<String> savedImageIds = [];
      if (imageIds.isNotEmpty) {
        print('  画像の保存を開始: ${imageIds.length}枚');
        savedImageIds.addAll(imageIds);
      }

      // APIに送信
      print('  APIにデータを送信');
      await _apiRepository.createItem(
        name: formData['itemName']?.toString() ?? '',
        color: formData['itemColor']?.toString(),
        description: formData['itemDescription']?.toString(),
        needsReceipt: formData['needsReceipt'] as bool? ?? false,
        routeName: formData['routeName']?.toString() ?? '',
        vehicleNumber: formData['vehicleNumber']?.toString() ?? '',
        otherLocation: formData['otherLocation']?.toString(),
        images: savedImageIds,
        finderName: formData['finderName']?.toString() ?? '',
        finderContact: formData['finderPhone']?.toString(),
        finderPostalCode: formData['postalCode']?.toString(),
        finderAddress: formData['finderAddress']?.toString(),
        cash: formData['cash'] as int?,
      );
      print('  API送信完了');

      // 下書きの削除
      if (draftId != null) {
        print('  下書きを削除: $draftId');
        await _repository.deleteDraft(draftId);
      }

      state = const AsyncValue.data(null);
      print('FormViewModel - フォーム送信完了\n');
    } catch (e, s) {
      print('FormViewModel - エラー発生: $e');
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> saveDraft(Map<String, dynamic> formData, List<String> imageIds,
      {String? draftId}) async {
    try {
      state = const AsyncValue.loading();
      print('FormViewModel - 下書き保存を開始');

      final now = DateTime.now();
      final draft = DraftItem(
        id: draftId ?? const Uuid().v4(),
        formData: formData,
        imageIds: imageIds,
        createdAt: now,
        updatedAt: now,
      );

      // 下書きを保存
      print('  下書きを保存: ${draft.id}');
      await _repository.saveDraft(draft);

      state = const AsyncValue.data(null);
      print('FormViewModel - 下書き保存完了\n');
    } catch (e, s) {
      print('FormViewModel - エラー発生: $e');
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<List<StoredImage>> loadImages(List<String> imageIds) async {
    try {
      print('FormViewModel - 画像の読み込みを開始: ${imageIds.length}枚');
      final images = await ImageStorage.getImages(imageIds, _imageRepository);
      print('  画像の読み込み完了: ${images.length}枚');
      return images;
    } catch (e) {
      print('FormViewModel - 画像の読み込みに失敗: $e');
      rethrow;
    }
  }

  Future<void> deleteDraft(String id) async {
    try {
      state = const AsyncValue.loading();
      print('FormViewModel - 下書き削除を開始: $id');

      final draft = _repository.getDraft(id);
      if (draft != null && draft.imageIds != null) {
        // 関連する画像を削除
        print('  関連画像を削除: ${draft.imageIds!.length}枚');
        for (final imageId in draft.imageIds!) {
          await _imageRepository.deleteImage(imageId);
        }
      }

      await _repository.deleteDraft(id);
      print('FormViewModel - 下書き削除完了');

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      print('FormViewModel - 下書き削除エラー:');
      print('  エラー: $e');
      print('  スタックトレース: $stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> removeImage(List<String> imageIds) async {
    try {
      print('FormViewModel - 画像の削除を開始: ${imageIds.length}枚');
      await ImageStorage.deleteImages(imageIds, _imageRepository);
      print('FormViewModel - 画像の削除完了');
    } catch (e) {
      print('FormViewModel - 画像の削除に失敗: $e');
      rethrow;
    }
  }

  Future<List<String>> addImages(List<String> imageIds) async {
    try {
      print('FormViewModel - 画像の追加を開始');
      print('  新規画像数: ${imageIds.length}枚');
      return imageIds;
    } catch (e) {
      print('FormViewModel - 画像の追加に失敗: $e');
      rethrow;
    }
  }
}
