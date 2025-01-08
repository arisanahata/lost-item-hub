import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../model/entities/form_data.dart';
import '../../../model/entities/stored_image.dart';
import '../../../model/repositories/local/image_repository.dart';
import '../../../util/image_storage.dart';
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

  Widget _buildBasicSection() {
    return SectionCard(
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
    );
  }

  Widget _buildLocationSection() {
    return SectionCard(
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
    );
  }

  Widget _buildDateSection() {
    return SectionCard(
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
    );
  }

  Widget _buildMemoSection() {
    return SectionCard(
      title: '権利確認',
      icon: Icons.gavel,
      child: Column(
        children: [
          _buildInfoRow(
            Icons.gavel,
            '権利放棄',
            formData['hasRightsWaiver'] == true ? '一切の権利を放棄' : '権利を保持する',
          ),
          if (formData['hasRightsWaiver'] == false) ...[
            _buildInfoRow(
              Icons.check_circle_outline,
              '保持する権利',
              _formatRightsOptions(
                  formData['rightsOptions'] as List<dynamic>? ?? []),
            ),
            _buildInfoRow(
              Icons.person_outline,
              '氏名等告知の同意',
              formData['hasConsentToDisclose'] == true ? '同意する' : '同意しない',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return SectionCard(
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
    );
  }

  Widget _buildImageSection(WidgetRef ref) {
    final imageIds = formData['images'] as List<dynamic>? ?? [];

    print('確認画面 - 画像セクション:');
    print('  画像ID: $imageIds');

    return SectionCard(
      title: '画像',
      icon: Icons.image,
      iconColor: Colors.grey[600],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: imageIds.map((id) {
                  return FutureBuilder<List<StoredImage>>(
                    future: ImageStorage.getImages(
                      [id.toString()],
                      ref.read(imageRepositoryProvider),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final image = snapshot.data!.first;
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: DecorationImage(
                            image: FileImage(File(image.filePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> onSubmit(BuildContext context, WidgetRef ref) async {
    final formViewModel = ref.read(formViewModelProvider.notifier);

    try {
      final imageIds = formData['images'] as List<dynamic>? ?? [];
      await formViewModel.submitForm(
        formData, 
        List<String>.from(imageIds),
        draftId: draftId
      );
      
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
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageRepository = ref.watch(imageRepositoryProvider);
    final formState = ref.watch(formViewModelProvider);
    final isSubmitting = formState is AsyncLoading;

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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBasicSection(),
                      _buildLocationSection(),
                      _buildDateSection(),
                      _buildMemoSection(),
                      _buildContactSection(),
                      _buildImageSection(ref),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSubmitting 
                          ? null 
                          : () => onSubmit(context, ref),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isSubmitting ? '送信中...' : '登録する',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isSubmitting)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class LostItem {
  final List<String> images;

  LostItem({required this.images});

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(images: json['images'] ?? []);
  }
}
