import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../component/section_card.dart';

class DateSection extends StatelessWidget {
  final Map<String, FocusNode>? nodes;
  final Map<String, dynamic>? initialData;
  final Function(String, dynamic)? onDateTimeChanged;
  final bool isEditing;

  const DateSection({
    super.key,
    this.nodes,
    this.initialData,
    this.onDateTimeChanged,
    this.isEditing = false,
  });

  Widget _buildFoundInfoSection() {
    return SectionCard(
      title: '拾得日時',
      icon: Icons.calendar_today,
      iconColor: Colors.grey[600],
      child: Row(
        children: [
          Expanded(
            child: FormBuilderDateTimePicker(
              name: 'foundDate',
              inputType: InputType.date,
              format: DateFormat('yyyy/MM/dd'),
              initialValue: isEditing && initialData != null
                  ? initialData!['foundDate'] as DateTime?
                  : DateTime.now(),
              decoration: InputDecoration(
                labelText: '拾得日 *',
                labelStyle: GoogleFonts.notoSans(fontSize: 16),
                prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
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
              validator:
                  FormBuilderValidators.required(errorText: '拾得日を入力してください'),
              onChanged: (value) => onDateTimeChanged?.call('foundDate', value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormBuilderDateTimePicker(
              name: 'foundTime',
              inputType: InputType.time,
              initialValue: isEditing && initialData != null
                  ? initialData!['foundTime'] as DateTime?
                  : DateTime.now(),
              decoration: InputDecoration(
                labelText: '拾得時刻',
                labelStyle: GoogleFonts.notoSans(fontSize: 16),
                prefixIcon: Icon(Icons.access_time, color: Colors.grey[600]),
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
              onChanged: (value) => onDateTimeChanged?.call('foundTime', value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildFoundInfoSection();
  }
}
