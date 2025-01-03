import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:expandable/expandable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lost_item_confirm_screen.dart';

class LostItemFormScreen extends HookConsumerWidget {
  LostItemFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>(), const []);
    final imagePicker = useMemoized(() => ImagePicker(), const []);
    final selectedImages = useState<List<XFile>>([]);
    final showRightsOptions = useState(false);
    final initialValues = useMemoized(
        () => {
              'foundDate': DateTime.now(),
              'foundTime': DateTime.now(),
              'hasRightsWaiver': false,
              'rightsOptions': <String>[],
              'hasConsentToDisclose': false,
              'finderName': '',
              'finderPhone': '',
              'postalCode': '',
              'finderAddress': '',
              'routeName': '',
              'vehicleNumber': '',
              'otherLocation': '',
              'yen10000': '0',
              'yen5000': '0',
              'yen2000': '0',
              'yen1000': '0',
              'yen500': '0',
              'yen100': '0',
              'yen50': '0',
              'yen10': '0',
              'yen5': '0',
              'yen1': '0',
              'itemName': '',
              'itemColor': '',
              'itemDescription': '',
              'needsReceipt': false,
            },
        const []);

    final filledFields = useState<Set<String>>({});

    // フィールド更新時の処理
    void onFieldChanged(String fieldName, dynamic value) {
      // フィールドの状態を更新
      if (value != null && value.toString().isNotEmpty) {
        filledFields.value = {...filledFields.value, fieldName};
      } else {
        filledFields.value = {...filledFields.value}..remove(fieldName);
      }

      // 特定のフィールドの追加処理
      if (fieldName == 'hasRightsWaiver') {
        showRightsOptions.value = value == false;
      }
    }

    Future<String?> searchAddress(String code) async {
      if (code.length != 7) return null;

      try {
        final response = await http.get(
          Uri.parse('https://zipcloud.ibsnet.co.jp/api/search?zipcode=$code'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final result = data['results'][0];
            final address =
                '${result['address1']}${result['address2']}${result['address3']}';

            formKey.currentState?.patchValue({
              'finderAddress': address,
            });
            onFieldChanged('finderAddress', address);

            return address;
          }
        }
        return null;
      } catch (e) {
        print('Error searching address: $e');
        return null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('遺失物連絡票'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: formKey,
        initialValue: initialValues,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSectionCard(
                  title: '権利確認',
                  icon: Icons.gavel,
                  iconColor: Colors.grey[600],
                  children: [
                    FormBuilderRadioGroup(
                      name: 'hasRightsWaiver',
                      decoration: InputDecoration(
                        labelText: '権利放棄',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      options: const [
                        FormBuilderFieldOption(
                            value: true, child: Text('一切の権利を放棄')),
                        FormBuilderFieldOption(
                            value: false, child: Text('権利を保持する')),
                      ],
                      onChanged: (value) =>
                          onFieldChanged('hasRightsWaiver', value),
                      activeColor: Colors.blue[700],
                    ),
                    if (showRightsOptions.value) ...[
                      const SizedBox(height: 16),
                      FormBuilderCheckboxGroup(
                        name: 'rightsOptions',
                        decoration: InputDecoration(
                          labelText: '保持する権利の選択',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.blue[700]!),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.red[300]!),
                          ),
                        ),
                        options: const [
                          FormBuilderFieldOption(
                              value: 'expense', child: Text('費用請求権')),
                          FormBuilderFieldOption(
                              value: 'reward', child: Text('報労金')),
                          FormBuilderFieldOption(
                              value: 'ownership', child: Text('所有権')),
                        ],
                        activeColor: Colors.blue[700],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: '拾得者情報',
                  icon: Icons.person,
                  iconColor: Colors.grey[600],
                  children: [
                    FormBuilderTextField(
                      name: 'finderName',
                      decoration: InputDecoration(
                        labelText: '氏名',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) => onFieldChanged('finderName', value),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'finderPhone',
                      decoration: InputDecoration(
                        labelText: '電話番号',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) =>
                          onFieldChanged('finderPhone', value),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: FormBuilderTextField(
                            name: 'postalCode',
                            decoration: InputDecoration(
                              labelText: '郵便番号',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.blue[700]!),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.red[300]!),
                              ),
                            ),
                            onChanged: (value) =>
                                onFieldChanged('postalCode', value),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final code = formKey
                                  .currentState?.fields['postalCode']?.value;
                              if (code != null && code.toString().length == 7) {
                                await searchAddress(code.toString());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: const Text('住所検索'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'finderAddress',
                      decoration: InputDecoration(
                        labelText: '住所',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) =>
                          onFieldChanged('finderAddress', value),
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: '拾得場所・日時',
                  icon: Icons.location_on,
                  iconColor: Colors.grey[600],
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'foundDate',
                            initialValue: DateTime.now(),
                            initialEntryMode: DatePickerEntryMode.calendar,
                            inputType: InputType.date,
                            format: DateFormat('yyyy/MM/dd'),
                            decoration: InputDecoration(
                              labelText: '拾得日',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.blue[700]!),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.red[300]!),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                onFieldChanged('foundDate',
                                    DateFormat('yyyy/MM/dd').format(value));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'foundTime',
                            initialValue: DateTime.now(),
                            decoration: InputDecoration(
                              labelText: '拾得時刻',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(color: Colors.blue[700]!),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.red[300]!),
                              ),
                            ),
                            inputType: InputType.time,
                            format: DateFormat('HH:mm'),
                            onChanged: (value) =>
                                onFieldChanged('foundTime', value?.toString()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'routeName',
                      decoration: InputDecoration(
                        labelText: '路線名',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) => onFieldChanged('routeName', value),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'vehicleNumber',
                      decoration: InputDecoration(
                        labelText: '車番',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) =>
                          onFieldChanged('vehicleNumber', value),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'otherLocation',
                      decoration: InputDecoration(
                        labelText: 'その他',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) =>
                          onFieldChanged('otherLocation', value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: '基本情報',
                  icon: Icons.info_outline,
                  iconColor: Colors.grey[600],
                  children: [
                    _buildCashSection(formKey),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'itemName',
                      decoration: InputDecoration(
                        labelText: '品名',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) => onFieldChanged('itemName', value),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'itemColor',
                      decoration: InputDecoration(
                        labelText: '色',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) => onFieldChanged('itemColor', value),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'itemDescription',
                      decoration: InputDecoration(
                        labelText: '品種・形状、特徴・内容',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      onChanged: (value) =>
                          onFieldChanged('itemDescription', value),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderCheckbox(
                      name: 'needsReceipt',
                      title: const Text('預り証発行有り'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      activeColor: Colors.blue[700],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final images = await imagePicker.pickMultiImage();
                              if (images != null) {
                                selectedImages.value = [
                                  ...selectedImages.value,
                                  ...images
                                ];
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('写真を追加'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LostItemConfirmScreen(
                              formData: formKey.currentState!.value,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      '確認',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCashInput(
      String name, String label, int value, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: FormBuilderTextField(
              name: name,
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: Colors.white,
                suffixText: '枚',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.blue[700]!),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: onChanged,
              valueTransformer: (value) => int.tryParse(value ?? '0') ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Builder(
              builder: (context) {
                final count = int.tryParse(
                      FormBuilder.of(context)
                              ?.fields[name]
                              ?.value
                              ?.toString() ??
                          '0',
                    ) ??
                    0;
                final amount = count * value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: amount > 0 ? Colors.blue[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '¥${NumberFormat('#,###').format(amount)}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSans(
                      color: amount > 0 ? Colors.blue[700] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashSection(GlobalKey<FormBuilderState> formKey) {
    final totalAmount = useState<int>(0);

    void calculateTotalAmount(FormBuilderState? state) {
      if (state == null) return;

      final amounts = {
        'yen10000': 10000,
        'yen5000': 5000,
        'yen2000': 2000,
        'yen1000': 1000,
        'yen500': 500,
        'yen100': 100,
        'yen50': 50,
        'yen10': 10,
        'yen5': 5,
        'yen1': 1,
      };

      int total = 0;
      amounts.forEach((key, value) {
        final count =
            int.tryParse(state.fields[key]?.value?.toString() ?? '0') ?? 0;
        total += count * value;
      });
      totalAmount.value = total;
    }

    return ExpandablePanel(
      theme: const ExpandableThemeData(
        headerAlignment: ExpandablePanelHeaderAlignment.center,
        tapBodyToExpand: true,
        tapBodyToCollapse: true,
        hasIcon: true,
        iconColor: Colors.grey,
        iconPadding: EdgeInsets.zero,
        iconRotationAngle: 3.14159 / 2,
      ),
      header: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_money, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '現金',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (totalAmount.value > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '¥${NumberFormat('#,###').format(totalAmount.value)}',
                  style: GoogleFonts.notoSans(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      collapsed: const SizedBox.shrink(),
      expanded: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            _buildCashInput('yen10000', '10,000円札', 10000,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen5000', '5,000円札', 5000,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen2000', '2,000円札', 2000,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen1000', '1,000円札', 1000,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen500', '500円玉', 500,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen100', '100円玉', 100,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen50', '50円玉', 50,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen10', '10円玉', 10,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen5', '5円玉', 5,
                (value) => calculateTotalAmount(formKey.currentState)),
            _buildCashInput('yen1', '1円玉', 1,
                (value) => calculateTotalAmount(formKey.currentState)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '合計金額',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '¥${NumberFormat('#,###').format(totalAmount.value)}',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
