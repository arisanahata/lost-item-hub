import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../viewmodel/form_viewmodel.dart';
import '../../component/form_button.dart';
import '../../sections/basic_section.dart';
import '../../sections/date_section.dart';
import '../../sections/finder_section.dart';
import '../../sections/image_section.dart';
import '../../sections/location_section.dart';
import '../../sections/rights_section.dart';
import 'lost_item_confirm_screen.dart';

class LostItemFormScreen extends HookConsumerWidget {
  final bool isEditing;
  final String? draftId;
  final Map<String, dynamic>? initialFormData;

  const LostItemFormScreen({
    Key? key,
    this.isEditing = false,
    this.draftId,
    this.initialFormData,
  }) : super(key: key);

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
    final isSaving = useState(false);
    final moneyControllers = useState<Map<String, TextEditingController>>({});
    final totalAmount = useState<int>(0);
    final isSubmitting = useState(false);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    // FocusNodeをuseMemoizedで作成
    final nodes = useMemoized(() {
      return {
        'itemName': FocusNode(),
        'itemDescription': FocusNode(),
        'foundDate': FocusNode(),
        'foundTime': FocusNode(),
        'locationPostalCode': FocusNode(),
        'locationAddress': FocusNode(),
        'routeName': FocusNode(),
        'vehicleNumber': FocusNode(),
        'finderName': FocusNode(),
        'finderContact': FocusNode(),
        'finderPostalCode': FocusNode(),
        'finderAddress': FocusNode(),
      };
    }, const []);

    // FocusNodeのクリーンアップ
    useEffect(() {
      return () {
        for (final node in nodes.values) {
          node.dispose();
        }
        for (var controller in moneyControllers.value.values) {
          controller.dispose();
        }
        animationController.dispose();
        scrollController.dispose();
      };
    }, const []);

    // フォームの値が変更されたときの処理
    void onFieldChanged(String fieldName, dynamic value) {
      if (fieldName == 'hasRightsWaiver') {
        showRightsOptions.value = !value;
      }
      if (value != null && value.toString().isNotEmpty) {
        filledFields.value = {...filledFields.value, fieldName};
      }
    }

    // 下書き保存の処理
    Future<void> saveDraft() async {
      if (formKey.value.currentState?.saveAndValidate() ?? false) {
        isSaving.value = true;
        try {
          await ref.read(draftListProvider.notifier).saveDraft(
                formKey.value.currentState!.value,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('下書きを保存しました')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('下書きの保存に失敗しました: $e')),
            );
          }
        } finally {
          isSaving.value = false;
        }
      }
    }

    Future<void> onSubmit() async {
      if (formKey.value.currentState?.saveAndValidate() ?? false) {
        isSubmitting.value = true;
        try {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LostItemConfirmScreen(
                formData: formKey.value.currentState!.value,
                draftId: draftId,
              ),
            ),
          );
        } finally {
          isSubmitting.value = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '拾得物編集' : '拾得物登録'),
      ),
      body: FormBuilder(
        key: formKey.value,
        initialValue: initialFormData ?? {},
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RightsSection(
                initialFormData: initialFormData,
                isEditing: isEditing,
                onFieldChanged: onFieldChanged,
              ),
              FinderSection(
                nodes: nodes,
                initialData: initialFormData,
                onFinderInfoChanged: onFieldChanged,
                formKey: formKey.value,
              ),
              DateSection(
                nodes: nodes,
                initialData: initialFormData,
                onDateTimeChanged: onFieldChanged,
                isEditing: isEditing,
              ),
              LocationSection(
                nodes: nodes,
                initialData: initialFormData,
                onFieldChanged: onFieldChanged,
              ),
              BasicSection(
                nodes: nodes,
                initialData: initialFormData,
                onFieldChanged: onFieldChanged,
                formKey: formKey.value,
                isEditing: isEditing,
              ),
              ImageSection(
                initialImages: selectedImages.value,
                onImagesChanged: (images) {
                  selectedImages.value = images;
                  formKey.value.currentState?.fields['images']
                      ?.didChange(images);
                },
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: fadeAnimation.value,
                    child: child,
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: FormButton(
                        text: '下書き保存',
                        onPressed: isSaving.value ? null : saveDraft,
                        isLoading: isSaving.value,
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FormButton(
                        text: '確認',
                        onPressed: isSubmitting.value ? null : onSubmit,
                        isLoading: isSubmitting.value,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
