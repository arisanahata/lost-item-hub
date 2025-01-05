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

  Future<void> searchAddress(String postalCode) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$postalCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0];
          final fullAddress =
              '${address['address1']}${address['address2']}${address['address3']}';
          formKey.currentState?.patchValue({'finderAddress': fullAddress});
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
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
            focusNode: nodes!['finderName'],
            decoration: AppStyle.getInputDecoration(
              labelText: '氏名',
              prefixIcon: Icons.person,
            ),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'finderPhone',
            focusNode: nodes!['finderPhone'],
            decoration: AppStyle.getInputDecoration(
              labelText: '電話番号',
              prefixIcon: Icons.phone,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: FormBuilderTextField(
                  name: 'postalCode',
                  focusNode: nodes!['postalCode'],
                  decoration: AppStyle.getInputDecoration(
                    labelText: '郵便番号',
                    prefixIcon: Icons.location_on,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // 空の場合はOK
                    }
                    // 入力がある場合は数字のみチェック
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return '数字のみ入力可能です';
                    }
                    return null;
                  },
                  onChanged: (value) => onFieldChanged('postalCode', value),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final code = formKey.currentState?.value['postalCode'];
                    if (code != null && code.toString().length == 7) {
                      await searchAddress(code.toString());
                    }
                  },
                  icon: const Icon(Icons.search, size: 18, color: Colors.white),
                  label: Text('住所検索',
                      style: GoogleFonts.notoSans(
                          color: Colors.white, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyle.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'finderAddress',
            focusNode: nodes!['finderAddress'],
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
