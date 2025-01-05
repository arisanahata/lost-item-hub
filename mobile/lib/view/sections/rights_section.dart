import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../component/section_card.dart';

class RightsSection extends HookWidget {
  final bool isEditing;
  final Map<String, dynamic>? initialFormData;
  final Function(String, dynamic)? onFieldChanged;

  const RightsSection({
    super.key,
    this.isEditing = false,
    this.initialFormData,
    this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showRightsOptions = useState(false);

    // 初期化処理
    useEffect(() {
      if (isEditing && initialFormData != null) {
        final hasRightsWaiver =
            initialFormData!['hasRightsWaiver'] as bool? ?? true;
        showRightsOptions.value = !hasRightsWaiver;
      }
      return null;
    }, [isEditing, initialFormData]);

    return SectionCard(
      title: '権利確認',
      icon: Icons.gavel,
      iconColor: Colors.grey[600],
      child: Column(
        children: [
          FormBuilderRadioGroup<bool>(
            name: 'hasRightsWaiver',
            initialValue: isEditing && initialFormData != null
                ? initialFormData!['hasRightsWaiver'] ?? true
                : true,
            decoration: const InputDecoration(
              labelText: '権利放棄',
            ),
            options: const [
              FormBuilderFieldOption(value: true, child: Text('一切の権利を放棄')),
              FormBuilderFieldOption(value: false, child: Text('権利を保持する')),
            ],
            onChanged: (value) {
              if (value != null) {
                showRightsOptions.value = !value;
                onFieldChanged?.call('hasRightsWaiver', value);
              }
            },
            activeColor: const Color.fromARGB(255, 12, 51, 135),
          ),
          if (showRightsOptions.value) ...[
            const SizedBox(height: 16),
            FormBuilderCheckboxGroup<String>(
              name: 'rightsOptions',
              decoration: const InputDecoration(
                labelText: '保持する権利の選択',
              ),
              initialValue: isEditing && initialFormData != null
                  ? (initialFormData!['rightsOptions'] as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      []
                  : [],
              options: const [
                FormBuilderFieldOption(
                  value: 'expense',
                  child: Text('費用請求権'),
                ),
                FormBuilderFieldOption(
                  value: 'reward',
                  child: Text('報労金請求権'),
                ),
                FormBuilderFieldOption(
                  value: 'ownership',
                  child: Text('所有権'),
                ),
              ],
              enabled: true,
              onChanged: (value) =>
                  onFieldChanged?.call('rightsOptions', value),
            ),
            const SizedBox(height: 16),
            FormBuilderRadioGroup(
              name: 'hasConsentToDisclose',
              initialValue: isEditing && initialFormData != null
                  ? initialFormData!['hasConsentToDisclose'] ?? true
                  : true,
              decoration: const InputDecoration(
                labelText: '氏名等告知の同意',
              ),
              options: const [
                FormBuilderFieldOption(value: true, child: Text('同意する')),
                FormBuilderFieldOption(value: false, child: Text('同意しない')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onFieldChanged?.call('hasConsentToDisclose', value);
                }
              },
              activeColor: const Color.fromARGB(255, 12, 51, 135),
            ),
          ],
        ],
      ),
    );
  }
}
