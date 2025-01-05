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
    final drafts = ref.watch(draftListProvider);

    return drafts.when(
      data: (items) {
        final draft = items.firstWhere((item) => item.id == draftId);
        return LostItemFormScreen(
          isEditing: true,
          draftId: draftId,
          initialFormData: draft.formData,
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
