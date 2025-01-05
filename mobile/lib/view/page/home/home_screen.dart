import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../viewmodel/form_viewmodel.dart';
import '../form/lost_item_form_screen.dart';
import '../form/lost_item_edit_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // フォーム画面と同じ背景色
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
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '下書き一覧',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final formData = item.formData;
                    final itemName = formData['itemName'] as String? ?? '';
                    final foundDate = formData['foundDate'] as DateTime?;
                    final foundTime = formData['foundTime'] as DateTime?;
                    final foundLocation =
                        formData['foundLocation'] as String? ?? '';
                    final routeName = formData['routeName'] as String? ?? '';
                    final vehicleNumber =
                        formData['vehicleNumber'] as String? ?? '';
                    final itemFeatures = formData['features'] as String? ?? '';

                    String dateStr = foundDate != null
                        ? DateFormat('yyyy/MM/dd').format(foundDate)
                        : '';
                    String timeStr = foundTime != null
                        ? DateFormat('HH:mm').format(foundTime)
                        : '';

                    // 拾得場所のテキストを構築
                    List<String> locationParts = [];
                    if (foundLocation.isNotEmpty) {
                      locationParts.add(foundLocation);
                    }
                    if (routeName.isNotEmpty) locationParts.add(routeName);
                    if (vehicleNumber.isNotEmpty) {
                      locationParts.add(vehicleNumber);
                    }
                    final locationText = locationParts.join(' ');

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              '下書きの削除',
                              style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'この下書きを削除してもよろしいですか？',
                              style: GoogleFonts.notoSans(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'キャンセル',
                                  style: GoogleFonts.notoSans(),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  '削除',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        try {
                          await ref
                              .read(formViewModelProvider.notifier)
                              .deleteDraft(item.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('下書きを削除しました'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('下書きの削除に失敗しました: $e'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
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
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LostItemEditScreen(
                                  draftId: item.id,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2,
                                          size: 20,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '遺失物の名称:',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            itemName.isEmpty ? '-' : itemName,
                                            style: GoogleFonts.notoSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                    if (dateStr.isNotEmpty ||
                                        locationText.isNotEmpty ||
                                        itemFeatures.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      if (dateStr.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.event,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '拾得日時:',
                                              style: GoogleFonts.notoSans(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                dateStr,
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (locationText.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '拾得場所:',
                                              style: GoogleFonts.notoSans(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                locationText,
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (itemFeatures.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.format_list_bulleted,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '特徴:',
                                              style: GoogleFonts.notoSans(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                itemFeatures,
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LostItemFormScreen(
                isEditing: false,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          '新規登録',
          style: GoogleFonts.notoSans(),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
