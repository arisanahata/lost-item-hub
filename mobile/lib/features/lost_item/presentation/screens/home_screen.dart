import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/draft_provider.dart';
import 'lost_item_form_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '忘れ物登録アプリ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: drafts.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '下書きはありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final draft = items[index];
              final formattedDate =
                  DateFormat('yyyy/MM/dd HH:mm').format(draft.updatedAt);

              return Dismissible(
                key: Key(draft.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red[700],
                  ),
                ),
                onDismissed: (_) {
                  ref.read(draftListProvider.notifier).deleteDraft(draft.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('下書きを削除しました'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LostItemFormScreen(draftId: draft.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.edit_note,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  draft.formData['finderName']?.toString() ??
                                      '名前なし',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '最終更新: $formattedDate',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LostItemFormScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeOutQuart;
                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
        backgroundColor: const Color(0xFF1a56db),
        elevation: 0,
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              const Icon(
                Icons.add,
                size: 28,
                color: Colors.white,  // アイコンの色を白に設定
              ),
              const SizedBox(width: 12),
              Text(
                '新規作成',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
