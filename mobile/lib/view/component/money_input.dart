import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expandable/expandable.dart';
import 'package:intl/intl.dart';

class MoneyInput extends HookWidget {
  final bool isEditing;
  final Map<String, dynamic>? initialFormData;
  final GlobalKey<FormBuilderState> formKey;
  final Function(String, dynamic)? onFieldChanged;

  const MoneyInput({
    super.key,
    this.isEditing = false,
    this.initialFormData,
    required this.formKey,
    this.onFieldChanged,
  });

  Widget _buildCashInput(
    String denomination,
    String label,
    int value,
    void Function(String?) onChanged,
    ValueNotifier<Map<String, TextEditingController>> moneyControllers,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: moneyControllers.value['yen$denomination'],
              decoration: InputDecoration(
                labelText: '$denomination円',
                labelStyle: GoogleFonts.notoSans(fontSize: 16),
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
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF1a56db)),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Builder(
              builder: (context) {
                final count = int.tryParse(
                    moneyControllers.value['yen$denomination']?.text ?? '0') ??
                    0;
                final amount = count * value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
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

  @override
  Widget build(BuildContext context) {
    final moneyControllers = useState<Map<String, TextEditingController>>({});
    final totalAmount = useState<int>(0);

    void calculateTotalAmount() {
      int sum = 0;
      final denominations = [
        '10000',
        '5000',
        '2000',
        '1000',
        '500',
        '100',
        '50',
        '10',
        '5',
        '1'
      ];
      for (var d in denominations) {
        final count =
            int.tryParse(moneyControllers.value['yen$d']?.text ?? '0') ?? 0;
        sum += count * int.parse(d);
      }
      totalAmount.value = sum;
    }

    void handleMoneyInput(String denomination, String? value) {
      final controller = moneyControllers.value['yen$denomination']!;

      if (value == null || value.isEmpty) {
        controller.text = '0';
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: 1),
        );
      } else {
        String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (newValue.startsWith('0') && newValue.length > 1) {
          newValue = newValue.substring(1);
        }
        controller.text = newValue;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: newValue.length),
        );
      }

      formKey.currentState?.fields['yen$denomination']
          ?.didChange(controller.text);
      calculateTotalAmount();
    }

    useEffect(() {
      final denominations = [
        '10000',
        '5000',
        '2000',
        '1000',
        '500',
        '100',
        '50',
        '10',
        '5',
        '1'
      ];
      final controllers = {
        for (var d in denominations)
          'yen$d': TextEditingController(
              text: isEditing && initialFormData != null
                  ? (initialFormData!['yen$d']?.toString() ?? '0')
                  : '0')
      };
      moneyControllers.value = controllers;

      if (isEditing && initialFormData != null) {
        if (initialFormData!['cash'] != null) {
          int remainingAmount = initialFormData!['cash'] as int;
          final denominations = [
            10000,
            5000,
            2000,
            1000,
            500,
            100,
            50,
            10,
            5,
            1
          ];

          for (var denom in denominations) {
            if (remainingAmount >= denom) {
              final count = remainingAmount ~/ denom;
              remainingAmount = remainingAmount % denom;
              moneyControllers.value['yen$denom']?.text = count.toString();
            }
          }
          calculateTotalAmount();
        }
      }

      return () {
        for (var controller in moneyControllers.value.values) {
          controller.dispose();
        }
      };
    }, []);

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
            _buildCashInput(
                '10000',
                '10,000円札',
                10000,
                (value) => handleMoneyInput('10000', value),
                moneyControllers),
            _buildCashInput(
                '5000',
                '5,000円札',
                5000,
                (value) => handleMoneyInput('5000', value),
                moneyControllers),
            _buildCashInput(
                '2000',
                '2,000円札',
                2000,
                (value) => handleMoneyInput('2000', value),
                moneyControllers),
            _buildCashInput(
                '1000',
                '1,000円札',
                1000,
                (value) => handleMoneyInput('1000', value),
                moneyControllers),
            _buildCashInput(
                '500',
                '500円玉',
                500,
                (value) => handleMoneyInput('500', value),
                moneyControllers),
            _buildCashInput(
                '100',
                '100円玉',
                100,
                (value) => handleMoneyInput('100', value),
                moneyControllers),
            _buildCashInput(
                '50',
                '50円玉',
                50,
                (value) => handleMoneyInput('50', value),
                moneyControllers),
            _buildCashInput(
                '10',
                '10円玉',
                10,
                (value) => handleMoneyInput('10', value),
                moneyControllers),
            _buildCashInput(
                '5',
                '5円玉',
                5,
                (value) => handleMoneyInput('5', value),
                moneyControllers),
            _buildCashInput(
                '1',
                '1円玉',
                1,
                (value) => handleMoneyInput('1', value),
                moneyControllers),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                      color: const Color(0xFF1a56db),
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
