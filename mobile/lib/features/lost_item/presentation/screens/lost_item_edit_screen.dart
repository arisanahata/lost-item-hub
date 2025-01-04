import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'lost_item_form_screen.dart';

class LostItemEditScreen extends HookConsumerWidget {
  final String draftId;

  const LostItemEditScreen({
    super.key,
    required this.draftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LostItemFormScreen(
      draftId: draftId,
      isEditing: true,
    );
  }
}
