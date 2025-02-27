import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../viewmodel/form_viewmodel.dart';
import '../../../model/entities/lost_item.dart';
import 'lost_item_form_screen.dart';

class LostItemEditScreen extends ConsumerWidget {
  final String draftId;

  const LostItemEditScreen({
    super.key,
    required this.draftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 特定のドラフトを監視
    final draftAsync = ref.watch(draftProvider(draftId));
    // FormViewModelの状態も監視
    final formState = ref.watch(formViewModelProvider);

    return draftAsync.when(
      data: (draft) {
        if (draft == null) {
          // ドラフトが見つからない場合
          return Scaffold(
            body: Center(
              child: Text('ドラフトが見つかりません: $draftId'),
            ),
          );
        }

        // 自動保存を開始
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(formViewModelProvider.notifier).startAutoSave(
                draft.formData,
                draft.imageIds ?? [],
              );
        });

        return LostItemFormScreen(
          isEditing: true,
          draftId: draftId,
          initialFormData: {
            ...draft.formData,
            'draft': draft, // draftオブジェクト全体を渡す
            'images': draft.imageIds ?? [], // 画像IDを追加
          },
        );
      },
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
