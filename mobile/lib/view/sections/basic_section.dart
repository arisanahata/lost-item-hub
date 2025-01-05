import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/section_card.dart';
import '../component/money_input.dart';

class BasicSection extends StatelessWidget {
  final Map<String, FocusNode>? nodes;
  final Map<String, dynamic>? initialData;
  final Function(String, dynamic)? onFieldChanged;
  final bool isEditing;
  final GlobalKey<FormBuilderState> formKey;

  const BasicSection({
    super.key,
    this.nodes,
    this.initialData,
    this.onFieldChanged,
    this.isEditing = false,
    required this.formKey,
  });

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
            focusNode: nodes!['itemName'],
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
            validator: FormBuilderValidators.required(errorText: '遺失物の名称を入力してください'),
            onChanged: (value) => onFieldChanged?.call('itemName', value),
          ),
          const SizedBox(height: 16),
          MoneyInput(
            formKey: formKey,
            isEditing: isEditing,
            initialFormData: initialData,
            onFieldChanged: onFieldChanged,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'itemColor',
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
            minLines: 3,
            maxLines: null,
            decoration: InputDecoration(
              labelText: '特徴など',
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
            onChanged: (value) => onFieldChanged?.call('itemDescription', value),
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
