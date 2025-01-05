import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../component/section_card.dart';
import '../style.dart';

class FinderSection extends StatelessWidget {
  final Map<String, FocusNode>? nodes;
  final Map<String, dynamic>? initialData;
  final Function(String, dynamic)? onFinderInfoChanged;
  final GlobalKey<FormBuilderState> formKey;

  const FinderSection({
    super.key,
    this.nodes,
    this.initialData,
    this.onFinderInfoChanged,
    required this.formKey,
  });

  void onFieldChanged(String field, dynamic value) {
    onFinderInfoChanged?.call(field, value);
  }

  Future<void> searchAddress(BuildContext context, String postalCode) async {
    try {
      // 郵便番号のフォーマットを整える（ハイフンを削除）
      final formattedCode = postalCode.replaceAll(RegExp(r'[^\d]'), '');
      if (formattedCode.length != 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('郵便番号は7桁で入力してください'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // ローディング表示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('住所を検索中...'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }

      final response = await http.get(
        Uri.parse(
            'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$formattedCode'),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0];
          final fullAddress =
              '${address['address1']}${address['address2']}${address['address3']}';

          // フォームの値を更新
          formKey.currentState?.patchValue({'finderAddress': fullAddress});

          // 成功メッセージを表示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('住所を取得しました'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // 該当する住所が見つからない場合
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('該当する住所が見つかりませんでした'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // APIエラーの場合
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('住所の取得に失敗しました'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFinderInfoSection() {
    return SectionCard(
      title: '拾得者情報',
      icon: Icons.person,
      iconColor: Colors.grey[600],
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'finderName',
            focusNode: nodes?['finderName'],
            initialValue: initialData?['finderName'],
            decoration: AppStyle.getInputDecoration(
              labelText: '氏名',
              prefixIcon: Icons.person,
            ),
            onChanged: (value) => onFieldChanged('finderName', value),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'finderPhone',
            focusNode: nodes?['finderPhone'],
            initialValue: initialData?['finderPhone'],
            decoration: AppStyle.getInputDecoration(
              labelText: '電話番号',
              prefixIcon: Icons.phone,
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => onFieldChanged('finderPhone', value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: FormBuilderTextField(
                  name: 'postalCode',
                  focusNode: nodes?['postalCode'],
                  initialValue: initialData?['postalCode'],
                  decoration: AppStyle.getInputDecoration(
                    labelText: '郵便番号',
                    prefixIcon: Icons.location_on,
                    hintText: '1234567',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // 空の場合はOK
                    }
                    // 入力がある場合は数字のみチェック
                    final formattedValue =
                        value.replaceAll(RegExp(r'[^\d]'), '');
                    if (formattedValue.length != 7) {
                      return '7桁の数字を入力してください';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(formattedValue)) {
                      return '数字のみ入力可能です';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      final formattedValue =
                          value.replaceAll(RegExp(r'[^\d]'), '');
                      onFinderInfoChanged?.call('postalCode', formattedValue);
                    }
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Builder(
                  builder: (context) => ElevatedButton.icon(
                    onPressed: () async {
                      final formState = formKey.currentState;
                      if (formState == null) {
                        print('Form state is null');
                        return;
                      }

                      final postalCodeField = formState.fields['postalCode'];
                      if (postalCodeField == null) {
                        print('Postal code field not found');
                        return;
                      }

                      final code = postalCodeField.value;
                      if (code != null && code.toString().isNotEmpty) {
                        await searchAddress(context, code.toString());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('郵便番号を入力してください'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    icon:
                        const Icon(Icons.search, size: 18, color: Colors.white),
                    label: Text(
                      '住所検索',
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'finderAddress',
            focusNode: nodes?['finderAddress'],
            initialValue: initialData?['finderAddress'],
            minLines: 2,
            maxLines: null,
            decoration: AppStyle.getInputDecoration(
              labelText: '住所',
              prefixIcon: Icons.home,
            ),
            onChanged: (value) => onFieldChanged('finderAddress', value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildFinderInfoSection();
  }
}
