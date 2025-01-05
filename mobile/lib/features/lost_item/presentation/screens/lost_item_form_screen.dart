import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lost_item_hub/features/lost_item/presentation/providers/draft_provider.dart';
import 'package:expandable/expandable.dart';
import 'home_screen.dart';
import 'lost_item_confirm_screen.dart';

class LostItemFormScreen extends HookConsumerWidget {
  final String? draftId;
  final bool isEditing;

  const LostItemFormScreen({
    super.key,
    this.draftId,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useState(GlobalKey<FormBuilderState>());
    final imagePicker = useMemoized(() => ImagePicker(), const []);
    final selectedImages = useState<List<XFile>>([]);
    final showRightsOptions = useState(false);
    final showButtons = useState(true);
    final scrollController = useScrollController();
    final isInteracting = useState(false);
    final filledFields = useState<Set<String>>({});
    final totalAmount = useState(0);

    // FocusNodeをuseMemoizedで作成
    final nodes = useMemoized(() {
      return {
        'postalCode': FocusNode(),
        'finderAddress': FocusNode(),
        'route': FocusNode(),
        'vehicle': FocusNode(),
        'itemName': FocusNode(),
        'finderName': FocusNode(),
        'finderPhone': FocusNode(),
      };
    }, const []);

    // FocusNodeのクリーンアップ
    useEffect(() {
      return () {
        for (final node in nodes.values) {
          node.dispose();
        }
      };
    }, const []);

    final cashController = useTextEditingController(text: '0');

    // フォームの値が変更されたときの処理
    void onFieldChanged(String fieldName, dynamic value) {
      if (value != null) {
        filledFields.value = {...filledFields.value, fieldName};
      } else {
        final newFilledFields = {...filledFields.value}..remove(fieldName);
        filledFields.value = newFilledFields;
      }

      if (fieldName == 'hasRightsWaiver') {
        showRightsOptions.value = value == false;
      }
    }

    // 現金入力の制御
    void handleCashInput(String? value) {
      if (value == null || value.isEmpty) {
        cashController.text = '0';
        cashController.selection = TextSelection.fromPosition(
          TextPosition(offset: cashController.text.length),
        );
        onFieldChanged('cash', '0');
        return;
      }

      // 数値以外の文字を削除
      String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');

      // 先頭の0を削除
      while (newValue.startsWith('0') && newValue.length > 1) {
        newValue = newValue.substring(1);
      }

      cashController.text = newValue;
      cashController.selection = TextSelection.fromPosition(
        TextPosition(offset: newValue.length),
      );

      // フォームの値を更新
      onFieldChanged('cash', newValue);
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
            formKey.value.currentState?.fields['finderAddress']
                ?.didChange(fullAddress);
          }
        }
      } catch (e) {
        print('Error fetching address: $e');
      }
    }

    void calculateTotalAmount(FormBuilderState? formState) {
      if (formState == null) return;

      final denominations = [
        'yen10000',
        'yen5000',
        'yen2000',
        'yen1000',
        'yen500',
        'yen100',
        'yen50',
        'yen10',
        'yen5',
        'yen1'
      ];

      final values = [10000, 5000, 2000, 1000, 500, 100, 50, 10, 5, 1];

      int total = 0;
      for (int i = 0; i < denominations.length; i++) {
        final count =
            int.tryParse(formState.fields[denominations[i]]?.value ?? '0') ?? 0;
        total += count * values[i];
      }

      totalAmount.value = total;
    }

    Widget _buildCashInput(String name, String label, int value,
        void Function(String?) onChanged) {
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
                  labelStyle: GoogleFonts.notoSans(fontSize: 16),
                  filled: true,
                  fillColor: Colors.white,
                  suffixText: '枚',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: const BorderSide(color: Color(0xFF1a56db))),
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
                  final count = int.tryParse(FormBuilder.of(context)
                              ?.fields[name]
                              ?.value
                              ?.toString() ??
                          '0') ??
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
                        color: amount > 0
                            ? const Color(0xFF1a56db)
                            : Colors.grey[600],
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
                    color: Colors.black87),
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
                        color: const Color(0xFF1a56db),
                        fontWeight: FontWeight.bold),
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
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '¥${NumberFormat('#,###').format(totalAmount.value)}',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1a56db)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildFoundInfoSection() {
      return _buildSectionCard(
        title: '拾得日時',
        icon: Icons.event,
        iconColor: Colors.grey[600],
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderDateTimePicker(
                  name: 'foundDate',
                  initialValue: !isEditing ? DateTime.now() : null,
                  inputType: InputType.date,
                  format: DateFormat('yyyy/MM/dd'),
                  decoration: InputDecoration(
                    labelText: '拾得日',
                    labelStyle: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.grey[400],
                    ),
                  ),
                  validator:
                      FormBuilderValidators.required(errorText: '拾得日を入力してください'),
                  onChanged: (value) {
                    if (value != null) {
                      onFieldChanged(
                          'foundDate', DateFormat('yyyy/MM/dd').format(value));
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderDateTimePicker(
                  name: 'foundTime',
                  initialValue: !isEditing ? DateTime.now() : null,
                  inputType: InputType.time,
                  format: DateFormat('HH:mm'),
                  decoration: InputDecoration(
                    labelText: '拾得時刻',
                    labelStyle: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: Icon(
                      Icons.access_time,
                      color: Colors.grey[400],
                    ),
                  ),
                  validator: FormBuilderValidators.required(
                      errorText: '拾得時刻を入力してください'),
                  onChanged: (value) {
                    if (value != null) {
                      onFieldChanged(
                          'foundTime', DateFormat('HH:mm').format(value));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'routeName',
                  focusNode: nodes['routeName'],
                  decoration: InputDecoration(
                    labelText: '路線',
                    labelStyle: GoogleFonts.notoSans(fontSize: 16),
                    prefixIcon: Icon(Icons.train, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'vehicleNumber',
                  decoration: InputDecoration(
                    labelText: '車番',
                    labelStyle: GoogleFonts.notoSans(fontSize: 16),
                    prefixIcon: Icon(Icons.numbers, color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'otherLocation',
            minLines: 2,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'その他の場所',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.place, color: Colors.grey[600]),
            ),
            onChanged: (value) => onFieldChanged('otherLocation', value),
          ),
        ],
      );
    }

    Widget _buildRightsWaiverSection() {
      return _buildSectionCard(
        title: '権利確認',
        icon: Icons.gavel,
        iconColor: Colors.grey[600],
        children: [
          FormBuilderRadioGroup(
            name: 'hasRightsWaiver',
            decoration: const InputDecoration(
              labelText: '権利放棄',
            ),
            options: const [
              FormBuilderFieldOption(value: true, child: Text('一切の権利を放棄')),
              FormBuilderFieldOption(value: false, child: Text('権利を保持する')),
            ],
            onChanged: (value) {
              showRightsOptions.value = value == false;
              onFieldChanged('hasRightsWaiver', value);
            },
            activeColor: const Color.fromARGB(255, 12, 51, 135),
          ),
          if (showRightsOptions.value) ...[
            const SizedBox(height: 16),
            FormBuilderCheckboxGroup(
              name: 'rightsOptions',
              decoration: const InputDecoration(
                labelText: '保持する権利の選択',
              ),
              options: const [
                FormBuilderFieldOption(value: 'expense', child: Text('費用請求権')),
                FormBuilderFieldOption(value: 'reward', child: Text('報労金')),
                FormBuilderFieldOption(value: 'ownership', child: Text('所有権')),
              ],
              activeColor: const Color.fromARGB(255, 12, 51, 135),
            ),
            const SizedBox(height: 16),
            FormBuilderRadioGroup(
              name: 'hasConsentToDisclose',
              decoration: const InputDecoration(
                labelText: '氏名等告知の同意',
              ),
              options: const [
                FormBuilderFieldOption(value: true, child: Text('同意する')),
                FormBuilderFieldOption(value: false, child: Text('同意しない')),
              ],
              onChanged: (value) =>
                  onFieldChanged('hasConsentToDisclose', value),
              activeColor: const Color.fromARGB(255, 12, 51, 135),
            ),
          ],
        ],
      );
    }

    Widget _buildItemInfoSection() {
      return _buildSectionCard(
        title: '基本情報',
        icon: Icons.info_outline,
        iconColor: Colors.grey[600],
        children: [
          FormBuilderTextField(
            name: 'itemName',
            focusNode: nodes['itemName'],
            decoration: InputDecoration(
              labelText: '遺失物の名称 *',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.inventory_2, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1a56db)),
              ),
            ),
            validator:
                FormBuilderValidators.required(errorText: '遺失物の名称を入力してください'),
            onChanged: (value) => onFieldChanged('itemName', value),
          ),
          const SizedBox(height: 16),
          _buildCashSection(formKey.value),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'itemColor',
            decoration: InputDecoration(
              labelText: '色',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.color_lens, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1a56db)),
              ),
            ),
            onChanged: (value) => onFieldChanged('itemColor', value),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'itemDescription',
            minLines: 3,
            maxLines: null,
            decoration: InputDecoration(
              labelText: '特徴など',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.description, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1a56db)),
              ),
            ),
            onChanged: (value) => onFieldChanged('itemDescription', value),
          ),
          const SizedBox(height: 16),
          FormBuilderRadioGroup(
            name: 'needsReceipt',
            decoration: const InputDecoration(
              labelText: '預り証発行',
            ),
            options: const [
              FormBuilderFieldOption(value: true, child: Text('有')),
              FormBuilderFieldOption(value: false, child: Text('無')),
            ],
            activeColor: const Color.fromARGB(255, 12, 51, 135),
          ),
        ],
      );
    }

    Widget _buildImageSection() {
      return _buildSectionCard(
        title: '画像',
        icon: Icons.photo_library,
        iconColor: Colors.grey[600],
        children: [
          OutlinedButton.icon(
            onPressed: () async {
              final images = await imagePicker.pickMultiImage();
              if (images != null) {
                selectedImages.value = [...selectedImages.value, ...images];
              }
            },
            icon: Icon(Icons.photo_camera_outlined,
                color: const Color.fromARGB(255, 12, 51, 135)),
            label: Text('写真を追加',
                style: GoogleFonts.notoSans(
                  color: const Color.fromARGB(255, 12, 51, 135),
                  fontSize: 16,
                )),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (selectedImages.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedImages.value.map((image) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(image.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          selectedImages.value = selectedImages.value
                              .where((img) => img.path != image.path)
                              .toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      );
    }

    Widget _buildFinderInfoSection() {
      return _buildSectionCard(
        title: '拾得者情報',
        icon: Icons.person,
        iconColor: Colors.grey[600],
        children: [
          FormBuilderTextField(
            name: 'finderName',
            focusNode: nodes['finderName'],
            decoration: InputDecoration(
              labelText: '氏名',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1a56db)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'finderPhone',
            focusNode: nodes['finderPhone'],
            decoration: InputDecoration(
              labelText: '電話番号',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1a56db)),
              ),
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
                  focusNode: nodes['postalCode'],
                  decoration: InputDecoration(
                    labelText: '郵便番号',
                    labelStyle: GoogleFonts.notoSans(fontSize: 16),
                    prefixIcon:
                        Icon(Icons.location_on, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1a56db)),
                    ),
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
                    final code =
                        formKey.value.currentState?.fields['postalCode']?.value;
                    if (code != null && code.toString().length == 7) {
                      await searchAddress(code.toString());
                    }
                  },
                  icon: const Icon(Icons.search, size: 18, color: Colors.white),
                  label: Text('住所検索',
                      style: GoogleFonts.notoSans(
                          color: Colors.white, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 12, 51, 135),
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
            focusNode: nodes['finderAddress'],
            minLines: 2,
            maxLines: null,
            decoration: InputDecoration(
              labelText: '住所',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1a56db)),
              ),
            ),
            onChanged: (value) => onFieldChanged('finderAddress', value),
          ),
        ],
      );
    }

    Widget _buildLocationSection() {
      return _buildSectionCard(
        title: '拾得場所',
        icon: Icons.place,
        iconColor: Colors.grey[600],
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'routeName',
                  focusNode: nodes['routeName'],
                  decoration: InputDecoration(
                    labelText: '路線',
                    labelStyle: GoogleFonts.notoSans(fontSize: 16),
                    prefixIcon: Icon(Icons.train, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1a56db)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'vehicleNumber',
                  decoration: InputDecoration(
                    labelText: '車番',
                    labelStyle: GoogleFonts.notoSans(fontSize: 16),
                    prefixIcon: Icon(Icons.numbers, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1a56db)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'otherLocation',
            minLines: 2,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'その他の場所',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.place, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1a56db)),
              ),
            ),
            onChanged: (value) => onFieldChanged('otherLocation', value),
          ),
        ],
      );
    }

    useEffect(() {
      return () {
        for (final node in nodes.values) {
          node.dispose();
        }
        cashController.dispose();
      };
    }, const []);

    // 初期データの読み込み
    useEffect(() {
      if (draftId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final draft =
              await ref.read(draftListProvider.notifier).getDraft(draftId!);
          if (draft != null) {
            final formData = Map<String, dynamic>.from(draft.formData);

            // 日付と時間の処理
            DateTime? foundDate;
            if (formData['foundDate'] != null &&
                formData['foundDate'] is String) {
              try {
                foundDate = DateTime.parse(formData['foundDate']);
              } catch (e) {
                print('Error parsing date: $e');
              }
            }

            // 時刻がStringの場合はDateTime形式に変換
            DateTime? foundTime;
            if (formData['foundTime'] != null &&
                formData['foundTime'] is String) {
              try {
                foundTime = DateFormat('HH:mm').parse(formData['foundTime']);
              } catch (e) {
                print('Error parsing time: $e');
              }
            }

            // フォームの値を設定
            formKey.value.currentState?.patchValue({
              'itemName': formData['itemName'] ?? '',
              'foundLocation': formData['foundLocation'] ?? '',
              'routeName': formData['routeName'] ?? '',
              'vehicleNumber': formData['vehicleNumber'] ?? '',
              'features': formData['features'] ?? '',
              'foundDate': foundDate,
              'foundTime': foundTime,
              'hasRightsWaiver': formData['hasRightsWaiver'] ?? true,
              'rightsOptions': formData['rightsOptions'] ?? <String>[],
              'hasConsentToDisclose': formData['hasConsentToDisclose'] ?? false,
              'isPersonalBelongings': formData['isPersonalBelongings'] ?? false,
              'hasIdentification': formData['hasIdentification'] ?? false,
              'hasValuables': formData['hasValuables'] ?? false,
              'isHighValue': formData['isHighValue'] ?? false,
              'isLowValue': formData['isLowValue'] ?? false,
              'isOrdinaryItem': formData['isOrdinaryItem'] ?? false,
              'isHandedOverToPolice': formData['isHandedOverToPolice'] ?? false,
              'isHandedOverToStation':
                  formData['isHandedOverToStation'] ?? false,
              'isHandedOverToOffice': formData['isHandedOverToOffice'] ?? false,
              'isHandedOverToOthers': formData['isHandedOverToOthers'] ?? false,
              'finderName': formData['finderName'] ?? '',
              'finderPhone': formData['finderPhone'] ?? '',
              'postalCode': formData['postalCode'] ?? '',
              'finderAddress': formData['finderAddress'] ?? '',
              'otherLocation': formData['otherLocation'] ?? '',
              'itemColor': formData['itemColor'] ?? '',
              'itemDescription': formData['itemDescription'] ?? '',
              'needsReceipt': formData['needsReceipt'] ?? false,
              'cash': formData['cash'] ?? '0',
            });

            // 権利関係のフィールドを確認
            showRightsOptions.value = !(formData['hasRightsWaiver'] ?? true);
          }
        });
      }
      return null;
    }, []);

    final Map<String, dynamic> initialValues = {
      'foundDate': !isEditing ? DateTime.now() : null,
      'foundTime':
          !isEditing ? DateFormat('HH:mm').format(DateTime.now()) : null,
      'hasRightsWaiver': true,
      'rightsOptions': <String>[],
      'hasConsentToDisclose': false,
      'finderName': '',
      'finderPhone': '',
      'postalCode': '',
      'finderAddress': '',
      'routeName': '',
      'vehicleNumber': '',
      'otherLocation': '',
      'cash': '0',
      'itemName': '',
      'itemColor': '',
      'itemDescription': '',
      'needsReceipt': false,
    };

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '拾得物の登録',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          if (showButtons.value)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final formState = formKey.value.currentState;
                        if (formState != null && formState.saveAndValidate()) {
                          final formData = formState.value;
                          ref
                              .read(draftListProvider.notifier)
                              .saveDraft(formData, draftId: draftId)
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    isEditing ? '上書き保存しました' : '下書きを保存しました'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          });
                        }
                      },
                      icon: const Icon(Icons.save_outlined,
                          size: 24, color: Colors.white),
                      label: Text(
                        isEditing ? '上書き保存' : '下書き保存',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 223, 170, 36),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final formState = formKey.value.currentState;
                        if (formState != null && formState.saveAndValidate()) {
                          final formData = formState.value;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LostItemConfirmScreen(formData: formData),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline,
                          size: 24, color: Colors.white),
                      label: Text(
                        '確認',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 12, 51, 135),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FormBuilder(
          key: formKey.value,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _buildRightsWaiverSection(),
              const SizedBox(height: 16),
              _buildFinderInfoSection(),
              const SizedBox(height: 16),
              _buildFoundInfoSection(),
              const SizedBox(height: 16),
              _buildLocationSection(),
              const SizedBox(height: 16),
              _buildItemInfoSection(),
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
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
                Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
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
}
