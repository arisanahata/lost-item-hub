import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../model/form_data.dart';
import '../../../model/stored_image.dart';
import '../../../model/repository/image_repository.dart';
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppStyle.iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRightsOptions(List<dynamic> options) {
    final Map<String, String> optionLabels = {
      'expense': '費用請求権',
      'reward': '報労金請求権',
      'ownership': '所有権',
    };
    return options
        .map((option) => optionLabels[option] ?? option.toString())
        .join('、');
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('yyyy/MM/dd').format(dateTime);
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildImageSection(List<String> imageIds, ImageRepository imageRepository) {
    return SectionCard(
      title: '画像',
      icon: Icons.image,
      iconColor: Colors.grey[600],
      child: imageIds.isEmpty
          ? const Text('画像なし')
          : GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
              children: imageIds.map((id) {
                return FutureBuilder<StoredImage?>(
                  future: imageRepository.getImage(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: MemoryImage(snapshot.data!.bytes),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = useState(false);
    final imageRepository = ref.watch(imageRepositoryProvider);

    Future<void> onSubmit() async {
      try {
        isSubmitting.value = true;
        // TODO: フォームの送信処理
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('拾得物の登録が完了しました')),
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

    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        title: Text(
          '内容確認',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SectionCard(
                      title: '基本情報',
                      icon: Icons.info,
                      iconColor: Colors.grey[600],
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.inventory_2,
                            '遺失物の名称',
                            formData['itemName'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.attach_money,
                            '現金',
                            formData['cash'] != null && formData['cash'] > 0
                                ? '${formData['cash']}円'
                                : '-',
                          ),
                          _buildInfoRow(
                            Icons.color_lens,
                            '色',
                            formData['itemColor'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.description,
                            '特徴など',
                            formData['itemDescription'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.receipt_long,
                            '預り証発行',
                            formData['needsReceipt'] == true ? '有' : '無',
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: '拾得場所',
                      icon: Icons.place_outlined,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.train,
                            '路線',
                            formData['routeName'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.numbers,
                            '車番',
                            formData['vehicleNumber'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.place,
                            'その他の場所',
                            formData['otherLocation'] ?? '',
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: '権利確認',
                      icon: Icons.gavel,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.gavel,
                            '権利放棄',
                            formData['hasRightsWaiver'] == true
                                ? '一切の権利を放棄'
                                : '権利を保持する',
                          ),
                          if (formData['hasRightsWaiver'] == false) ...[
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              '保持する権利',
                              _formatRightsOptions(
                                  formData['rightsOptions'] as List<dynamic>? ??
                                      []),
                            ),
                            _buildInfoRow(
                              Icons.person_outline,
                              '氏名等告知の同意',
                              formData['hasConsentToDisclose'] == true
                                  ? '同意する'
                                  : '同意しない',
                            ),
                          ],
                        ],
                      ),
                    ),
                    SectionCard(
                      title: '拾得日時',
                      icon: Icons.calendar_today,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.calendar_today,
                            '拾得日',
                            _formatDateTime(formData['foundDate']),
                          ),
                          _buildInfoRow(
                            Icons.access_time,
                            '拾得時刻',
                            _formatTime(formData['foundTime']),
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: '拾得者情報',
                      icon: Icons.person,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.person,
                            '氏名',
                            formData['finderName'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.phone,
                            '連絡先',
                            formData['finderContact'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.location_on,
                            '郵便番号',
                            formData['finderPostalCode'] ?? '',
                          ),
                          _buildInfoRow(
                            Icons.home,
                            '住所',
                            formData['finderAddress'] ?? '',
                          ),
                        ],
                      ),
                    ),
                    if (formData['draft'] != null &&
                        formData['draft'].imagePaths != null)
                      _buildImageSection(
                        List<String>.from(formData['draft'].imagePaths!),
                        imageRepository,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppStyle.secondaryButtonStyle,
                    child: Text(
                      '修正する',
                      style: AppStyle.secondaryButtonTextStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting.value ? null : onSubmit,
                    style: AppStyle.primaryButtonStyle,
                    child: isSubmitting.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            '登録する',
                            style: AppStyle.buttonTextStyle,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
