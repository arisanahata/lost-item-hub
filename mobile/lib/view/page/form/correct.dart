// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive/hive.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:lost_item_hub/features/lost_item/presentation/providers/draft_provider.dart';
// import 'package:expandable/expandable.dart';
// import '../../domain/entities/lost_item.dart';
// import 'home_screen.dart';
// import 'lost_item_confirm_screen.dart';

// class LostItemFormScreen extends HookConsumerWidget {
//   final bool isEditing;
//   final String? draftId;
//   final Map<String, dynamic>? initialFormData;

//   const LostItemFormScreen({
//     Key? key,
//     this.isEditing = false,
//     this.draftId,
//     this.initialFormData,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final formKey = useState(GlobalKey<FormBuilderState>());
//     final imagePicker = useMemoized(() => ImagePicker(), const []);
//     final selectedImages = useState<List<XFile>>([]);
//     final showRightsOptions = useState(false);
//     final showButtons = useState(true);
//     final scrollController = useScrollController();
//     final isInteracting = useState(false);
//     final filledFields = useState<Set<String>>({});
//     final moneyControllers = useState<Map<String, TextEditingController>>({});
//     final totalAmount = useState<int>(0);
//     final animationController = useAnimationController(
//       duration: const Duration(milliseconds: 300),
//     );
//     final fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeInOut,
//     ));

//     // FocusNodeをuseMemoizedで作成
//     final nodes = useMemoized(() {
//       return {
//         'postalCode': FocusNode(),
//         'finderAddress': FocusNode(),
//         'route': FocusNode(),
//         'vehicle': FocusNode(),
//         'itemName': FocusNode(),
//         'finderName': FocusNode(),
//         'finderPhone': FocusNode(),
//       };
//     }, const []);

//     // FocusNodeのクリーンアップ
//     useEffect(() {
//       return () {
//         for (final node in nodes.values) {
//           node.dispose();
//         }
//       };
//     }, const []);

//     // 合計金額の計算
//     void calculateTotalAmount() {
//       int sum = 0;
//       final denominations = [
//         '10000',
//         '5000',
//         '2000',
//         '1000',
//         '500',
//         '100',
//         '50',
//         '10',
//         '5',
//         '1'
//       ];
//       for (var d in denominations) {
//         final count =
//             int.tryParse(moneyControllers.value['yen$d']?.text ?? '0') ?? 0;
//         sum += count * int.parse(d);
//       }
//       totalAmount.value = sum;
//     }

//     // 金額入力の処理
//     void handleMoneyInput(String denomination, String? value) {
//       final controller = moneyControllers.value['yen$denomination']!;

//       if (value == null || value.isEmpty) {
//         controller.text = '0';
//         controller.selection = TextSelection.fromPosition(
//           TextPosition(offset: 1),
//         );
//       } else {
//         String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
//         if (newValue.startsWith('0') && newValue.length > 1) {
//           newValue = newValue.substring(1);
//         }
//         controller.text = newValue;
//         controller.selection = TextSelection.fromPosition(
//           TextPosition(offset: newValue.length),
//         );
//       }

//       // フォームの値を更新
//       formKey.value.currentState?.fields['yen$denomination']
//           ?.didChange(controller.text);

//       // 合計金額を計算
//       calculateTotalAmount();
//     }

//     useEffect(() {
//       // 金額入力フィールドのコントローラーを初期化
//       final denominations = [
//         '10000',
//         '5000',
//         '2000',
//         '1000',
//         '500',
//         '100',
//         '50',
//         '10',
//         '5',
//         '1'
//       ];
//       final controllers = {
//         for (var d in denominations)
//           'yen$d': TextEditingController(
//               text: isEditing && initialFormData != null
//                   ? (initialFormData!['yen$d']?.toString() ?? '0')
//                   : '0')
//       };
//       moneyControllers.value = controllers;

//       // 初期の合計金額を計算
//       if (isEditing && initialFormData != null) {
//         calculateTotalAmount();
//       }

//       return () {
//         for (var controller in moneyControllers.value.values) {
//           controller.dispose();
//         }
//       };
//     }, []);

//     // フォームの値が変更されたときの処理
//     void onFieldChanged(String fieldName, dynamic value) {
//       if (fieldName == 'hasRightsWaiver') {
//         showRightsOptions.value = !value;
//       }
//     }

//     // 現金入力の制御
//     void handleCashInput(String? value) {
//       if (value == null || value.isEmpty) {
//         return;
//       }

//       // 数値以外の文字を削除
//       String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');

//       // 先頭の0を削除
//       while (newValue.startsWith('0') && newValue.length > 1) {
//         newValue = newValue.substring(1);
//       }

//       // フォームの値を更新
//       onFieldChanged('cash', newValue);
//     }

//     Future<void> searchAddress(String postalCode) async {
//       try {
//         final response = await http.get(
//           Uri.parse(
//               'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$postalCode'),
//         );

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);
//           if (data['results'] != null && data['results'].isNotEmpty) {
//             final address = data['results'][0];
//             final fullAddress =
//                 '${address['address1']}${address['address2']}${address['address3']}';
//             formKey.value.currentState?.fields['finderAddress']
//                 ?.didChange(fullAddress);
//           }
//         }
//       } catch (e) {
//         print('Error fetching address: $e');
//       }
//     }

//     Widget _buildCashInput(String denomination, String label, int value,
//         void Function(String?) onChanged) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 8.0),
//         child: Row(
//           children: [
//             Expanded(
//               flex: 2,
//               child: TextFormField(
//                 controller: moneyControllers.value['yen$denomination'],
//                 decoration: InputDecoration(
//                   labelText: '$denomination円',
//                   labelStyle: GoogleFonts.notoSans(fontSize: 16),
//                   filled: true,
//                   fillColor: Colors.white,
//                   suffixText: '枚',
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(8)),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: const BorderRadius.all(Radius.circular(8)),
//                     borderSide: BorderSide(color: Colors.grey[300]!),
//                   ),
//                   focusedBorder: const OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(8)),
//                     borderSide: BorderSide(color: Color(0xFF1a56db)),
//                   ),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => handleMoneyInput(denomination, value),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               flex: 1,
//               child: Builder(
//                 builder: (context) {
//                   final count = int.tryParse(
//                           moneyControllers.value['yen$denomination']?.text ??
//                               '0') ??
//                       0;
//                   final amount = count * value;
//                   return Container(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       color: amount > 0 ? Colors.blue[50] : Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       '¥${NumberFormat('#,###').format(amount)}',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.notoSans(
//                         color: amount > 0
//                             ? const Color(0xFF1a56db)
//                             : Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     Widget _buildCashSection(GlobalKey<FormBuilderState> formKey) {
//       return ExpandablePanel(
//         theme: const ExpandableThemeData(
//           headerAlignment: ExpandablePanelHeaderAlignment.center,
//           tapBodyToExpand: true,
//           tapBodyToCollapse: true,
//           hasIcon: true,
//           iconColor: Colors.grey,
//           iconPadding: EdgeInsets.zero,
//           iconRotationAngle: 3.14159 / 2,
//         ),
//         header: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.attach_money, color: Colors.grey[600]),
//               const SizedBox(width: 8),
//               Text(
//                 '現金',
//                 style: GoogleFonts.notoSans(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87),
//               ),
//               const Spacer(),
//               if (totalAmount.value > 0)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     '${totalAmount.value}円',
//                     style: GoogleFonts.notoSans(
//                         color: const Color(0xFF1a56db),
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         collapsed: const SizedBox.shrink(),
//         expanded: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Column(
//             children: [
//               _buildCashInput('10000', '10,000円札', 10000,
//                   (value) => handleMoneyInput('10000', value)),
//               _buildCashInput('5000', '5,000円札', 5000,
//                   (value) => handleMoneyInput('5000', value)),
//               _buildCashInput('2000', '2,000円札', 2000,
//                   (value) => handleMoneyInput('2000', value)),
//               _buildCashInput('1000', '1,000円札', 1000,
//                   (value) => handleMoneyInput('1000', value)),
//               _buildCashInput('500', '500円玉', 500,
//                   (value) => handleMoneyInput('500', value)),
//               _buildCashInput('100', '100円玉', 100,
//                   (value) => handleMoneyInput('100', value)),
//               _buildCashInput(
//                   '50', '50円玉', 50, (value) => handleMoneyInput('50', value)),
//               _buildCashInput(
//                   '10', '10円玉', 10, (value) => handleMoneyInput('10', value)),
//               _buildCashInput(
//                   '5', '5円玉', 5, (value) => handleMoneyInput('5', value)),
//               _buildCashInput(
//                   '1', '1円玉', 1, (value) => handleMoneyInput('1', value)),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '合計金額',
//                       style: GoogleFonts.notoSans(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       '${totalAmount.value}円',
//                       style: GoogleFonts.notoSans(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF1a56db),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     Widget _buildFoundInfoSection() {
//       return _buildSectionCard(
//         title: '拾得日時',
//         icon: Icons.calendar_today,
//         iconColor: Colors.grey[600],
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: FormBuilderDateTimePicker(
//                   name: 'foundDate',
//                   inputType: InputType.date,
//                   format: DateFormat('yyyy/MM/dd'),
//                   initialValue: isEditing && initialFormData != null
//                       ? initialFormData!['foundDate'] as DateTime?
//                       : DateTime.now(),
//                   decoration: InputDecoration(
//                     labelText: '拾得日 *',
//                     labelStyle: GoogleFonts.notoSans(fontSize: 16),
//                     prefixIcon:
//                         Icon(Icons.calendar_today, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8))),
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Colors.grey[300]!)),
//                     focusedBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Color(0xFF1a56db))),
//                   ),
//                   validator:
//                       FormBuilderValidators.required(errorText: '拾得日を入力してください'),
//                   onChanged: (value) => onFieldChanged('foundDate', value),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: FormBuilderDateTimePicker(
//                   name: 'foundTime',
//                   inputType: InputType.time,
//                   initialValue: isEditing && initialFormData != null
//                       ? initialFormData!['foundTime'] as DateTime?
//                       : DateTime.now(),
//                   decoration: InputDecoration(
//                     labelText: '拾得時刻',
//                     labelStyle: GoogleFonts.notoSans(fontSize: 16),
//                     prefixIcon:
//                         Icon(Icons.access_time, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8))),
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Colors.grey[300]!)),
//                     focusedBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Color(0xFF1a56db))),
//                   ),
//                   onChanged: (value) => onFieldChanged('foundTime', value),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     }

//     Widget _buildRightsWaiverSection() {
//       return _buildSectionCard(
//         title: '権利確認',
//         icon: Icons.gavel,
//         iconColor: Colors.grey[600],
//         children: [
//           FormBuilderRadioGroup(
//             name: 'hasRightsWaiver',
//             initialValue: isEditing && initialFormData != null
//                 ? initialFormData!['hasRightsWaiver'] ?? true
//                 : true,
//             decoration: const InputDecoration(
//               labelText: '権利放棄',
//             ),
//             options: const [
//               FormBuilderFieldOption(value: true, child: Text('一切の権利を放棄')),
//               FormBuilderFieldOption(value: false, child: Text('権利を保持する')),
//             ],
//             onChanged: (value) {
//               onFieldChanged('hasRightsWaiver', value);
//             },
//             activeColor: const Color.fromARGB(255, 12, 51, 135),
//           ),
//           if (showRightsOptions.value) ...[
//             const SizedBox(height: 16),
//             FormBuilderCheckboxGroup<String>(
//               name: 'rightsOptions',
//               decoration: const InputDecoration(
//                 labelText: '保持する権利の選択',
//               ),
//               initialValue: isEditing && initialFormData != null
//                   ? (initialFormData!['rightsOptions'] as List<dynamic>)
//                       .map((e) => e.toString())
//                       .toList()
//                   : [],
//               options: const [
//                 FormBuilderFieldOption(
//                   value: 'expense',
//                   child: Text('費用請求権'),
//                 ),
//                 FormBuilderFieldOption(
//                   value: 'reward',
//                   child: Text('報労金請求権'),
//                 ),
//                 FormBuilderFieldOption(
//                   value: 'ownership',
//                   child: Text('所有権'),
//                 ),
//               ],
//               enabled: true,
//               onChanged: (value) => onFieldChanged('rightsOptions', value),
//             ),
//             const SizedBox(height: 16),
//             FormBuilderRadioGroup(
//               name: 'hasConsentToDisclose',
//               initialValue: isEditing && initialFormData != null
//                   ? initialFormData!['hasConsentToDisclose'] ?? true
//                   : true,
//               decoration: const InputDecoration(
//                 labelText: '氏名等告知の同意',
//               ),
//               options: const [
//                 FormBuilderFieldOption(value: true, child: Text('同意する')),
//                 FormBuilderFieldOption(value: false, child: Text('同意しない')),
//               ],
//               onChanged: (value) =>
//                   onFieldChanged('hasConsentToDisclose', value),
//               activeColor: const Color.fromARGB(255, 12, 51, 135),
//             ),
//           ],
//         ],
//       );
//     }

//     Widget _buildItemInfoSection() {
//       return _buildSectionCard(
//         title: '基本情報',
//         icon: Icons.info_outline,
//         iconColor: Colors.grey[600],
//         children: [
//           FormBuilderTextField(
//             name: 'itemName',
//             focusNode: nodes['itemName'],
//             decoration: InputDecoration(
//               labelText: '遺失物の名称 *',
//               labelStyle: GoogleFonts.notoSans(fontSize: 16),
//               prefixIcon: Icon(Icons.inventory_2, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Color(0xFF1a56db))),
//             ),
//             validator:
//                 FormBuilderValidators.required(errorText: '遺失物の名称を入力してください'),
//             onChanged: (value) => onFieldChanged('itemName', value),
//           ),
//           const SizedBox(height: 16),
//           _buildCashSection(formKey.value),
//           const SizedBox(height: 16),
//           FormBuilderTextField(
//             name: 'itemColor',
//             decoration: InputDecoration(
//               labelText: '色',
//               labelStyle: GoogleFonts.notoSans(fontSize: 16),
//               prefixIcon: Icon(Icons.color_lens, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Color(0xFF1a56db))),
//             ),
//             onChanged: (value) => onFieldChanged('itemColor', value),
//           ),
//           const SizedBox(height: 16),
//           FormBuilderTextField(
//             name: 'itemDescription',
//             minLines: 3,
//             maxLines: null,
//             decoration: InputDecoration(
//               labelText: '特徴など',
//               labelStyle: GoogleFonts.notoSans(fontSize: 16),
//               prefixIcon: Icon(Icons.description, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Color(0xFF1a56db))),
//             ),
//             onChanged: (value) => onFieldChanged('itemDescription', value),
//           ),
//           const SizedBox(height: 16),
//           FormBuilderRadioGroup(
//             name: 'needsReceipt',
//             initialValue: isEditing && initialFormData != null
//                 ? initialFormData!['needsReceipt'] ?? false
//                 : false,
//             decoration: const InputDecoration(
//               labelText: '預り証発行',
//             ),
//             options: const [
//               FormBuilderFieldOption(value: true, child: Text('有')),
//               FormBuilderFieldOption(value: false, child: Text('無')),
//             ],
//             activeColor: const Color.fromARGB(255, 12, 51, 135),
//           ),
//         ],
//       );
//     }

//     Widget _buildImageSection() {
//       return _buildSectionCard(
//         title: '画像',
//         icon: Icons.photo_library,
//         iconColor: Colors.grey[600],
//         children: [
//           OutlinedButton.icon(
//             onPressed: () async {
//               final images = await imagePicker.pickMultiImage();
//               if (images != null) {
//                 selectedImages.value = [...selectedImages.value, ...images];
//               }
//             },
//             icon: Icon(Icons.photo_camera_outlined,
//                 color: const Color.fromARGB(255, 12, 51, 135)),
//             label: Text('写真を追加',
//                 style: GoogleFonts.notoSans(
//                   color: const Color.fromARGB(255, 12, 51, 135),
//                   fontSize: 16,
//                 )),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               side: BorderSide(color: Colors.grey[400]!),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           if (selectedImages.value.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: selectedImages.value.map((image) {
//                 return Stack(
//                   children: [
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         image: DecorationImage(
//                           image: FileImage(File(image.path)),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: GestureDetector(
//                         onTap: () {
//                           selectedImages.value = selectedImages.value
//                               .where((img) => img.path != image.path)
//                               .toList();
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.close,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ],
//         ],
//       );
//     }

//     Widget _buildFinderInfoSection() {
//       return _buildSectionCard(
//         title: '拾得者情報',
//         icon: Icons.person,
//         iconColor: Colors.grey[600],
//         children: [
//           FormBuilderTextField(
//             name: 'finderName',
//             focusNode: nodes['finderName'],
//             decoration: InputDecoration(
//               labelText: '氏名',
//               labelStyle: GoogleFonts.notoSans(fontSize: 16),
//               prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Color(0xFF1a56db))),
//             ),
//           ),
//           const SizedBox(height: 16),
//           FormBuilderTextField(
//             name: 'finderPhone',
//             focusNode: nodes['finderPhone'],
//             decoration: InputDecoration(
//               labelText: '電話番号',
//               labelStyle: GoogleFonts.notoSans(fontSize: 16),
//               prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Color(0xFF1a56db))),
//             ),
//             keyboardType: TextInputType.phone,
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 flex: 4,
//                 child: FormBuilderTextField(
//                   name: 'postalCode',
//                   focusNode: nodes['postalCode'],
//                   decoration: InputDecoration(
//                     labelText: '郵便番号',
//                     labelStyle: GoogleFonts.notoSans(fontSize: 16),
//                     prefixIcon:
//                         Icon(Icons.location_on, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8))),
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Colors.grey[300]!)),
//                     focusedBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Color(0xFF1a56db))),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return null; // 空の場合はOK
//                     }
//                     // 入力がある場合は数字のみチェック
//                     if (!RegExp(r'^\d+$').hasMatch(value)) {
//                       return '数字のみ入力可能です';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) => onFieldChanged('postalCode', value),
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 flex: 3,
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     final code =
//                         formKey.value.currentState?.fields['postalCode']?.value;
//                     if (code != null && code.toString().length == 7) {
//                       await searchAddress(code.toString());
//                     }
//                   },
//                   icon: const Icon(Icons.search, size: 18, color: Colors.white),
//                   label: Text('住所検索',
//                       style: GoogleFonts.notoSans(
//                           color: Colors.white, fontSize: 15)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 12, 51, 135),
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           FormBuilderTextField(
//             name: 'finderAddress',
//             focusNode: nodes['finderAddress'],
//             minLines: 2,
//             maxLines: null,
//             decoration: InputDecoration(
//               labelText: '住所',
//               labelStyle: GoogleFonts.notoSans(fontSize: 16),
//               prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Color(0xFF1a56db))),
//             ),
//             onChanged: (value) => onFieldChanged('finderAddress', value),
//           ),
//         ],
//       );
//     }

//     Widget _buildLocationSection() {
//       return _buildSectionCard(
//         title: '拾得場所',
//         icon: Icons.place,
//         iconColor: Colors.grey[600],
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: FormBuilderTextField(
//                   name: 'routeName',
//                   focusNode: nodes['routeName'],
//                   decoration: InputDecoration(
//                     labelText: '路線',
//                     labelStyle: GoogleFonts.notoSans(fontSize: 16),
//                     prefixIcon: Icon(Icons.train, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8))),
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Colors.grey[300]!)),
//                     focusedBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Color(0xFF1a56db))),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: FormBuilderTextField(
//                   name: 'vehicleNumber',
//                   decoration: InputDecoration(
//                     labelText: '車番',
//                     labelStyle: GoogleFonts.notoSans(fontSize: 16),
//                     prefixIcon: Icon(Icons.numbers, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8))),
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Colors.grey[300]!)),
//                     focusedBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Color(0xFF1a56db))),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           FormBuilderTextField(
//             name: 'otherLocation',
//             minLines: 2,
//             maxLines: null,
//             decoration: InputDecoration(
//               labelText: 'その他の場所',
//               labelStyle: GoogleFonts.notoSans(fontSize: 16),
//               prefixIcon: Icon(Icons.place, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.white,
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   borderSide: BorderSide(color: Color(0xFF1a56db))),
//             ),
//             onChanged: (value) => onFieldChanged('otherLocation', value),
//           ),
//         ],
//       );
//     }

//     useEffect(() {
//       if (isEditing && initialFormData != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           print('=== 編集画面の初期データ ===');
//           print('権利放棄: ${initialFormData!['hasRightsWaiver']}');
//           print('権利オプション: ${initialFormData!['rightsOptions']}');
//           print('権利オプションの型: ${initialFormData!['rightsOptions']?.runtimeType}');
//           print('==================');

//           // 権利放棄の状態を設定
//           final hasRightsWaiver = initialFormData!['hasRightsWaiver'] ?? true;
//           showRightsOptions.value = !hasRightsWaiver;

//           print('=== フォーム設定前の状態 ===');
//           print('showRightsOptions: ${showRightsOptions.value}');
//           print(
//               'hasRightsWaiver field: ${formKey.value.currentState?.fields['hasRightsWaiver']?.value}');
//           print(
//               'rightsOptions field: ${formKey.value.currentState?.fields['rightsOptions']?.value}');
//           print('==================');

//           // フォームの値を設定（権利オプション以外）
//           formKey.value.currentState?.patchValue({
//             ...initialFormData!,
//             'hasRightsWaiver': hasRightsWaiver,
//           });

//           print('=== patchValue後の状態 ===');
//           print(
//               'hasRightsWaiver field: ${formKey.value.currentState?.fields['hasRightsWaiver']?.value}');
//           print(
//               'rightsOptions field: ${formKey.value.currentState?.fields['rightsOptions']?.value}');
//           print('==================');

//           // 権利オプションを個別に設定
//           if (!hasRightsWaiver && initialFormData!['rightsOptions'] != null) {
//             // 既存の選択をクリア
//             formKey.value.currentState?.fields['rightsOptions']?.reset();

//             // 新しい選択を設定
//             final options = (initialFormData!['rightsOptions'] as List)
//                 .map((e) => e.toString())
//                 .toList();
//             print('=== 設定する権利オプション ===');
//             print('options: $options');
//             print('options type: ${options.runtimeType}');
//             print('==================');

//             formKey.value.currentState?.fields['rightsOptions']
//                 ?.didChange(options);

//             print('=== 権利オプション設定後の状態 ===');
//             print(
//                 'rightsOptions field: ${formKey.value.currentState?.fields['rightsOptions']?.value}');
//             print('==================');
//           }

//           // 現金の設定
//           if (initialFormData!['cash'] != null) {
//             int remainingAmount = initialFormData!['cash'] as int;
//             final denominations = [
//               10000,
//               5000,
//               2000,
//               1000,
//               500,
//               100,
//               50,
//               10,
//               5,
//               1
//             ];

//             for (var denom in denominations) {
//               if (remainingAmount >= denom) {
//                 final count = remainingAmount ~/ denom;
//                 remainingAmount = remainingAmount % denom;
//                 moneyControllers.value['yen$denom']?.text = count.toString();
//               }
//             }
//             // 合計金額を更新
//             calculateTotalAmount();
//           }
//         });
//       }
//       return null;
//     }, [initialFormData]);

//     useEffect(() {
//       animationController.forward();
//       return null;
//     }, []);

//     return FadeTransition(
//       opacity: fadeAnimation,
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           title: Text(
//             isEditing ? '忘れ物情報編集' : '忘れ物情報登録',
//             style: GoogleFonts.notoSans(),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(
//                   builder: (context) => const HomeScreen(),
//                 ),
//                 (route) => false,
//               );
//             },
//           ),
//         ),
//         body: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: FormBuilder(
//             key: formKey.value,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildRightsWaiverSection(),
//                   const SizedBox(height: 16),
//                   _buildFinderInfoSection(),
//                   const SizedBox(height: 16),
//                   _buildFoundInfoSection(),
//                   const SizedBox(height: 16),
//                   _buildLocationSection(),
//                   const SizedBox(height: 16),
//                   _buildItemInfoSection(),
//                   const SizedBox(height: 16),
//                   _buildImageSection(),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     final formState = formKey.value.currentState;
//                     if (formState != null && formState.saveAndValidate()) {
//                       // 変更可能な新しいマップを作成
//                       final formData =
//                           Map<String, dynamic>.from(formState.value);
//                       // 合計金額を追加
//                       formData['cash'] = totalAmount.value;

//                       print('=== フォームデータ ===');
//                       print('権利放棄: ${formData['hasRightsWaiver']}');
//                       print('氏名公表: ${formData['hasNameDisclosure']}');
//                       print('現金: ${formData['cash']}');
//                       print(
//                           '日時: ${formData['foundDate']}, ${formData['foundTime']}');
//                       print('その他のデータ: $formData');
//                       print('==================');

//                       ref
//                           .read(draftListProvider.notifier)
//                           .saveDraft(formData, draftId: draftId)
//                           .then((_) {
//                         if (context.mounted) {
//                           // まずSnackBarを表示
//                           final messenger = ScaffoldMessenger.of(context);
//                           messenger.showSnackBar(
//                             SnackBar(
//                               content:
//                                   Text(isEditing ? '上書き保存しました' : '下書き保存しました'),
//                               behavior: SnackBarBehavior.floating,
//                               duration: const Duration(seconds: 2),
//                             ),
//                           );

//                           // 少し遅延させてから画面遷移
//                           Future.delayed(const Duration(milliseconds: 500), () {
//                             if (context.mounted) {
//                               Navigator.pop(context);
//                             }
//                           });
//                         }
//                       });
//                     }
//                   },
//                   icon: const Icon(Icons.save_outlined,
//                       size: 24, color: Colors.white),
//                   label: Text(
//                     isEditing ? '上書き保存' : '下書き保存',
//                     style: GoogleFonts.notoSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 223, 170, 36),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     final formState = formKey.value.currentState;
//                     if (formState != null && formState.saveAndValidate()) {
//                       final formData = formState.value;
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               LostItemConfirmScreen(formData: formData),
//                         ),
//                       );
//                     }
//                   },
//                   icon: const Icon(Icons.check_circle_outline,
//                       size: 24, color: Colors.white),
//                   label: Text(
//                     '確認',
//                     style: GoogleFonts.notoSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 12, 51, 135),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionCard({
//     required String title,
//     required IconData icon,
//     Color? iconColor,
//     required List<Widget> children,
//   }) {
//     return Card(
//       elevation: 0,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: GoogleFonts.notoSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800]),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
// }
