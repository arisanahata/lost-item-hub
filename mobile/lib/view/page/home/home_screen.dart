import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/entities/stored_image.dart';
import '../../../model/repositories/local/image_repository.dart';
import '../../../viewmodel/form_viewmodel.dart';
import '../../component/form_button.dart';
import '../../style.dart';
import '../form/lost_item_form_screen.dart';
import '../form/lost_item_edit_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftListProvider);
    final imageRepository = ref.read(imageRepositoryProvider);

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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        LostItemEditScreen(
                                  draftId: item.id,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                                reverseTransitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: // サムネイル画像
                                        item.imageIds != null &&
                                                item.imageIds!.isNotEmpty
                                            ? FutureBuilder<StoredImage?>(
                                                future: Future.value(
                                                    imageRepository.getImage(
                                                        item.imageIds!.first)),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .waiting ||
                                                      !snapshot.hasData) {
                                                    return Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  }

                                                  return Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                      image: DecorationImage(
                                                        image: FileImage(File(
                                                            snapshot
                                                                .data!.path)),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.grey[100],
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 32,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 16, 0, 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      itemName.isEmpty
                                                          ? '-'
                                                          : itemName,
                                                      style:
                                                          GoogleFonts.notoSans(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[800],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (item.imageIds != null &&
                                                  item.imageIds!.length > 1)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .photo_library_outlined,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${item.imageIds!.length}枚',
                                                        style: GoogleFonts
                                                            .notoSans(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildInfoRow(
                                            Icons.event_outlined,
                                            '拾得日時',
                                            dateStr.isEmpty && timeStr.isEmpty
                                                ? '-'
                                                : '$dateStr ${timeStr.isEmpty ? '' : timeStr}',
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            Icons.place_outlined,
                                            '拾得場所',
                                            locationText.isEmpty
                                                ? '-'
                                                : locationText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 132, // サムネイルの高さに合わせる
                                    padding: const EdgeInsets.only(right: 8),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
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
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LostItemFormScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        icon: const Icon(
          Icons.add,
          size: 24,
          color: Colors.white,
        ),
        label: Text(
          '新規作成',
          style: AppStyle.buttonTextStyle,
        ),
        backgroundColor: AppStyle.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  // 情報行を構築するヘルパーメソッド
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
