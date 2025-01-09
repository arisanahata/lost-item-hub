import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/section_card.dart';
import '../component/money_input.dart';

class BasicSection extends StatelessWidget {
  final Map<String, FocusNode> nodes;
  final Map<String, dynamic>? initialData;
  final Function(String, dynamic)? onFieldChanged;
  final GlobalKey<FormBuilderState> formKey;
  final bool isEditing;
  final ValueNotifier<int>? totalAmount;

  const BasicSection({
    Key? key,
    required this.nodes,
    this.initialData,
    this.onFieldChanged,
    required this.formKey,
    required this.isEditing,
    this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '基本情報',
      icon: Icons.info_outline,
      iconColor: Colors.grey[600],
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'itemName',
            focusNode: nodes['itemName'],
            initialValue: initialData?['itemName'],
            decoration: InputDecoration(
              labelText: '遺失物の名称 *',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.inventory_2, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF1a56db))),
            ),
            validator: (value) {
              if (isEditing) {
                return value == null || value.isEmpty
                    ? '遺失物の名称を入力してください'
                    : null;
              }
              return null;
            },
            onChanged: (value) {
              // 値が変更されたときだけ通知
              if (value != formKey.currentState?.fields['itemName']?.value) {
                print('BasicSection - 名称が変更されました: $value');
                onFieldChanged?.call('itemName', value);
              }
            },
          ),
          const SizedBox(height: 16),
          // 現金データ用の非表示フィールド
          FormBuilderField<int>(
            name: 'cash',
            initialValue: initialData?['cash'] ?? 0,
            builder: (FormFieldState<int> field) {
              return const SizedBox.shrink();
            },
          ),
          MoneyInput(
            isEditing: isEditing,
            initialFormData: initialData,
            formKey: formKey,
            onFieldChanged: (field, value) {
              print('BasicSection - 現金データが更新されました:');
              print('  フィールド名: $field');
              print('  値: $value');

              print('BasicSection - フォームの状態を更新');
              Future.microtask(() {
                if (formKey.currentState?.fields['cash'] != null) {
                  formKey.currentState?.fields['cash']?.didChange(value);
                  print('  フォームの値を更新: $value');
                } else {
                  print('  cash フィールドが見つかりません');
                }

                print('BasicSection - 親コンポーネントに通知');
                onFieldChanged?.call('cash', value);
              });
            },
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'itemColor',
            initialValue: initialData?['itemColor'],
            decoration: InputDecoration(
              labelText: '色',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.color_lens, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF1a56db))),
            ),
            onChanged: (value) => onFieldChanged?.call('itemColor', value),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'itemDescription',
            initialValue: initialData?['itemDescription'],
            decoration: InputDecoration(
              labelText: '特徴・状態',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.description, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF1a56db))),
            ),
            maxLines: 3,
            onChanged: (value) =>
                onFieldChanged?.call('itemDescription', value),
          ),
          const SizedBox(height: 16),
          FormBuilderRadioGroup(
            name: 'needsReceipt',
            initialValue: isEditing && initialData != null
                ? initialData!['needsReceipt'] ?? false
                : false,
            decoration: InputDecoration(
              labelText: '預り証発行',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              border: InputBorder.none,
            ),
            options: const [
              FormBuilderFieldOption(value: true, child: Text('有')),
              FormBuilderFieldOption(value: false, child: Text('無')),
            ],
            activeColor: const Color(0xFF1a56db),
          ),
        ],
      ),
    );
  }
}
