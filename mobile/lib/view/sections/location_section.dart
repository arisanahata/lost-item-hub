import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/section_card.dart';

class LocationSection extends StatelessWidget {
  final Map<String, FocusNode>? nodes;
  final Map<String, dynamic>? initialData;
  final Function(String, dynamic)? onFieldChanged;

  const LocationSection({
    super.key,
    this.nodes,
    this.initialData,
    this.onFieldChanged,
  });

  Widget _buildLocationSection() {
    return SectionCard(
      title: '拾得場所',
      icon: Icons.place,
      iconColor: Colors.grey[600],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'routeName',
                  focusNode: nodes!['routeName'],
                  decoration: InputDecoration(
                    labelText: '路線',
                    labelStyle: GoogleFonts.notoSans(fontSize: 16),
                    prefixIcon: Icon(Icons.train, color: Colors.grey[600]),
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
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'vehicleNumber',
                  focusNode: nodes!['vehicleNumber'],
                  decoration: InputDecoration(
                    labelText: '車番',
                    labelStyle: GoogleFonts.notoSans(fontSize: 16),
                    prefixIcon: Icon(Icons.numbers, color: Colors.grey[600]),
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'otherLocation',
            focusNode: nodes!['otherLocation'],
            minLines: 2,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'その他の場所',
              labelStyle: GoogleFonts.notoSans(fontSize: 16),
              prefixIcon: Icon(Icons.place, color: Colors.grey[600]),
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
            onChanged: (value) => onFieldChanged?.call('otherLocation', value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildLocationSection();
  }
}
