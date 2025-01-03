import 'dart:async';
import 'dart:convert';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lost_item_hub/features/lost_item/presentation/providers/draft_provider.dart';
import 'home_screen.dart';
import 'lost_item_confirm_screen.dart';

class LostItemFormScreen extends HookConsumerWidget {
  final String? draftId;

  const LostItemFormScreen({
    super.key,
    this.draftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useState(GlobalKey<FormBuilderState>());
    final imagePicker = useMemoized(() => ImagePicker(), const []);
    final selectedImages = useState<List<XFile>>([]);
    final showRightsOptions = useState(false);
    final showButtons = useState(true);
    final scrollController = useScrollController();
    final timer = useState<Timer?>(null);
    final isInteracting = useState(false);

    void hideButtons() {
      showButtons.value = false;
      timer.value?.cancel();
    }

    void startShowButtonsTimer() {
      if (!isInteracting.value) {
        timer.value = Timer(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            showButtons.value = true;
          }
        });
      }
    }

    useEffect(() {
      void listener() {
        if (!scrollController.hasClients) return;
        if (scrollController.position.isScrollingNotifier.value) {
          isInteracting.value = true;
          hideButtons();
        } else {
          isInteracting.value = false;
          startShowButtonsTimer();
        }
      }

      if (scrollController.hasClients) {
        scrollController.position.isScrollingNotifier.addListener(listener);
      }

      return () {
        if (scrollController.hasClients) {
          scrollController.position.isScrollingNotifier
              .removeListener(listener);
        }
      };
    }, [scrollController]);

    // Create and memoize FocusNodes
    final nodes = useMemoized(
        () => {
              'name': FocusNode(),
              'phone': FocusNode(),
              'postalCode': FocusNode(),
              'address': FocusNode(),
              'route': FocusNode(),
              'vehicle': FocusNode(),
              'otherLocation': FocusNode(),
              'itemName': FocusNode(),
              'itemColor': FocusNode(),
              'itemDescription': FocusNode(),
            },
        []);

    // Handle focus changes and cleanup
    useEffect(() {
      void focusListener() {
        final hasFocus = nodes.values.any((node) => node.hasFocus);
        if (hasFocus) {
          hideButtons();
        } else {
          startShowButtonsTimer();
        }
      }

      // Add listeners
      nodes.values.forEach((node) => node.addListener(focusListener));

      // Cleanup
      return () {
        try {
          for (final node in nodes.values) {
            if (node.hasListeners) {
              node.removeListener(focusListener);
            }
            node.dispose();
          }
        } catch (e) {
          // Ignore errors during cleanup
        }
      };
    }, []);

    final Map<String, dynamic> initialValues = {
      'foundDate': DateTime.now(),
      'foundTime': DateTime.now(),
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
    };

    final filledFields = useState<Set<String>>({});

    void onFieldChanged(String fieldName, dynamic value) {
      if (value != null && value.toString().isNotEmpty) {
        filledFields.value = {...filledFields.value, fieldName};
      } else {
        filledFields.value = {...filledFields.value}..remove(fieldName);
      }

      if (fieldName == 'hasRightsWaiver') {
        showRightsOptions.value = value == false;
      }
    }

    Future<String?> searchAddress(String code) async {
      if (code.length != 7) return null;

      try {
        final response = await http.get(Uri.parse(
            'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$code'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final result = data['results'][0];
            final address =
                '${result['address1']}${result['address2']}${result['address3']}';

            formKey.value.currentState?.patchValue({'finderAddress': address});
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

    useEffect(() {
      if (draftId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final draft =
              await ref.read(draftListProvider.notifier).getDraft(draftId!);
          if (draft != null) {
            formKey.value.currentState?.patchValue(draft.formData);
          }
        });
      }
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '忘れ物登録',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Stack(
        children: [
          FormBuilder(
            key: formKey.value,
            initialValue: initialValues,
            child: Listener(
              onPointerDown: (_) {
                isInteracting.value = true;
                hideButtons();
              },
              onPointerUp: (_) {
                isInteracting.value = false;
                startShowButtonsTimer();
              },
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 120, // ボタンの高さ + 余白分のパディングを追加
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
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
                            FormBuilderFieldOption(
                                value: true, child: Text('一切の権利を放棄')),
                            FormBuilderFieldOption(
                                value: false, child: Text('権利を保持する')),
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
                              FormBuilderFieldOption(
                                  value: 'expense', child: Text('費用請求権')),
                              FormBuilderFieldOption(
                                  value: 'reward', child: Text('報労金')),
                              FormBuilderFieldOption(
                                  value: 'ownership', child: Text('所有権')),
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
                              FormBuilderFieldOption(
                                  value: true, child: Text('同意する')),
                              FormBuilderFieldOption(
                                  value: false, child: Text('同意しない')),
                            ],
                            onChanged: (value) =>
                                onFieldChanged('hasConsentToDisclose', value),
                            activeColor: const Color.fromARGB(255, 12, 51, 135),
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
                          focusNode: nodes['name'],
                          decoration: InputDecoration(
                            labelText: '氏名',
                            labelStyle: GoogleFonts.notoSans(fontSize: 16),
                            prefixIcon:
                                Icon(Icons.person, color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'finderPhone',
                          focusNode: nodes['phone'],
                          decoration: InputDecoration(
                            labelText: '電話番号',
                            labelStyle: GoogleFonts.notoSans(fontSize: 16),
                            prefixIcon:
                                Icon(Icons.phone, color: Colors.grey[600]),
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
                                  labelStyle:
                                      GoogleFonts.notoSans(fontSize: 16),
                                  prefixIcon: Icon(Icons.location_on,
                                      color: Colors.grey[600]),
                                ),
                                validator: FormBuilderValidators.numeric(
                                    errorText: '数字のみ入力可能です'),
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
                                  final code = formKey.value.currentState
                                      ?.fields['postalCode']?.value;
                                  if (code != null &&
                                      code.toString().length == 7) {
                                    await searchAddress(code.toString());
                                  }
                                },
                                icon: Icon(Icons.search,
                                    size: 18, color: Colors.white),
                                label: Text('住所検索',
                                    style: GoogleFonts.notoSans(
                                        color: Colors.white, fontSize: 15)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 12, 51, 135),
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
                          focusNode: nodes['address'],
                          decoration: InputDecoration(
                            labelText: '住所',
                            labelStyle: GoogleFonts.notoSans(fontSize: 16),
                            prefixIcon:
                                Icon(Icons.home, color: Colors.grey[600]),
                          ),
                          onChanged: (value) =>
                              onFieldChanged('finderAddress', value),
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: '拾得日時',
                      icon: Icons.event,
                      iconColor: Colors.grey[600],
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderDateTimePicker(
                                name: 'foundDate',
                                inputType: InputType.date,
                                format: DateFormat('yyyy/MM/dd'),
                                decoration: InputDecoration(
                                  labelText: '拾得日 *',
                                  labelStyle:
                                      GoogleFonts.notoSans(fontSize: 16),
                                  prefixIcon: Icon(Icons.calendar_today,
                                      color: Colors.grey[600]),
                                ),
                                validator: FormBuilderValidators.required(
                                    errorText: '拾得日を入力してください'),
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
                                inputType: InputType.time,
                                decoration: InputDecoration(
                                  labelText: '拾得時刻 *',
                                  labelStyle:
                                      GoogleFonts.notoSans(fontSize: 16),
                                  prefixIcon: Icon(Icons.access_time,
                                      color: Colors.grey[600]),
                                ),
                                validator: FormBuilderValidators.required(
                                    errorText: '拾得時刻を入力してください'),
                                onChanged: (value) => onFieldChanged(
                                    'foundTime', value?.toString()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: '拾得場所',
                      icon: Icons.place,
                      iconColor: Colors.grey[600],
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'routeName',
                                focusNode: nodes['route'],
                                decoration: InputDecoration(
                                  labelText: '路線',
                                  labelStyle:
                                      GoogleFonts.notoSans(fontSize: 16),
                                  prefixIcon: Icon(Icons.train,
                                      color: Colors.grey[600]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'vehicleNumber',
                                focusNode: nodes['vehicle'],
                                decoration: InputDecoration(
                                  labelText: '車番',
                                  labelStyle:
                                      GoogleFonts.notoSans(fontSize: 16),
                                  prefixIcon: Icon(Icons.numbers,
                                      color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'otherLocation',
                          focusNode: nodes['otherLocation'],
                          decoration: InputDecoration(
                            labelText: 'その他の場所',
                            labelStyle: GoogleFonts.notoSans(fontSize: 16),
                            prefixIcon:
                                Icon(Icons.place, color: Colors.grey[600]),
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
                        _buildCashSection(formKey.value),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'itemName',
                          focusNode: nodes['itemName'],
                          decoration: InputDecoration(
                            labelText: '遺失物の名称 *',
                            labelStyle: GoogleFonts.notoSans(fontSize: 16),
                            prefixIcon: Icon(Icons.inventory_2,
                                color: Colors.grey[600]),
                          ),
                          validator: FormBuilderValidators.required(
                              errorText: '遺失物の名称を入力してください'),
                          onChanged: (value) =>
                              onFieldChanged('itemName', value),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'itemColor',
                          focusNode: nodes['itemColor'],
                          decoration: InputDecoration(
                            labelText: '色',
                            labelStyle: GoogleFonts.notoSans(fontSize: 16),
                            prefixIcon:
                                Icon(Icons.color_lens, color: Colors.grey[600]),
                          ),
                          onChanged: (value) =>
                              onFieldChanged('itemColor', value),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'itemDescription',
                          focusNode: nodes['itemDescription'],
                          decoration: InputDecoration(
                            labelText: '特徴など',
                            labelStyle: GoogleFonts.notoSans(fontSize: 16),
                            prefixIcon: Icon(Icons.description,
                                color: Colors.grey[600]),
                          ),
                          onChanged: (value) =>
                              onFieldChanged('itemDescription', value),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderRadioGroup(
                          name: 'needsReceipt',
                          decoration: const InputDecoration(
                            labelText: '預り証発行',
                          ),
                          options: const [
                            FormBuilderFieldOption(
                                value: true, child: Text('有')),
                            FormBuilderFieldOption(
                                value: false, child: Text('無')),
                          ],
                          activeColor: const Color.fromARGB(255, 12, 51, 135),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final images = await imagePicker.pickMultiImage();
                            if (images != null) {
                              selectedImages.value = [
                                ...selectedImages.value,
                                ...images
                              ];
                            }
                          },
                          icon: Icon(Icons.photo_camera_outlined,
                              color: const Color.fromARGB(255, 12, 51, 135)),
                          label: Text('写真を追加',
                              style: Theme.of(context).textTheme.bodyMedium),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showButtons.value)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.value.currentState?.saveAndValidate() ??
                                false) {
                              await ref
                                  .read(draftListProvider.notifier)
                                  .saveDraft(formKey.value.currentState!.value,
                                      draftId: draftId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('下書きを保存しました')));
                                Navigator.pop(context);
                              }
                            }
                          },
                          icon: const Icon(Icons.save_outlined,
                              size: 24, color: Colors.white),
                          label: Text(
                            '下書き保存',
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
                            if (formKey.value.currentState?.saveAndValidate() ??
                                false) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LostItemConfirmScreen(
                                    formData: formKey.value.currentState!.value,
                                  ),
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
                            backgroundColor:
                                const Color.fromARGB(255, 12, 51, 135),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
}
