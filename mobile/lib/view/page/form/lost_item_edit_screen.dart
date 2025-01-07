import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../viewmodel/form_viewmodel.dart';
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

        return LostItemFormScreen(
          isEditing: true,
          draftId: draftId,
          initialFormData: {
            ...draft.formData,
            'draft': draft,  // draftオブジェクト全体を渡す
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
