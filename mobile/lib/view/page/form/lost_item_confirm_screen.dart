import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../viewmodel/form_viewmodel.dart';
import '../../style.dart';
import '../../component/section_card.dart';

class LostItemConfirmScreen extends HookConsumerWidget {
  final Map<String, dynamic> formData;
  final String? draftId;

  const LostItemConfirmScreen({
    Key? key,
    required this.formData,
    this.draftId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(formViewModelProvider);
    final isSubmitting = useState(false);

    Future<void> onSubmit() async {
      try {
        isSubmitting.value = true;
        await ref
            .read(formViewModelProvider.notifier)
            .submitForm(formData, draftId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('拾得物の届出が完了しました')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    Widget _buildConfirmSection(String title, Map<String, dynamic> data) {
      return SectionCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((entry) {
            if (entry.value == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value.toString(),
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '内容確認',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildConfirmSection('基本情報', {
                '遺失物の名称': formData['itemName'],
                '特徴': formData['itemDescription'],
                '現金': formData['cash'] != null ? '¥${formData['cash']}' : null,
              }),
              const SizedBox(height: 16),
              _buildConfirmSection('拾得日時', {
                '拾得日': formData['foundDate']?.toString().split(' ')[0],
                '拾得時刻': formData['foundTime']?.toString().split(' ')[1],
              }),
              const SizedBox(height: 16),
              _buildConfirmSection('拾得場所', {
                '郵便番号': formData['locationPostalCode'],
                '住所': formData['locationAddress'],
                '路線': formData['routeName'],
                '車両': formData['vehicleNumber'],
              }),
              const SizedBox(height: 16),
              _buildConfirmSection('拾得者情報', {
                '氏名': formData['finderName'],
                '連絡先': formData['finderContact'],
                '郵便番号': formData['finderPostalCode'],
                '住所': formData['finderAddress'],
              }),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: AppStyle.secondaryButtonStyle,
                      child: Text(
                        '戻る',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting.value ? null : onSubmit,
                      style: AppStyle.primaryButtonStyle,
                      child: Text(
                        '提出',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isSubmitting.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
