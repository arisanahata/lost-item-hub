import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../viewmodel/form_viewmodel.dart';
import '../../sections/basic_section.dart';
import '../../sections/date_section.dart';
import '../../sections/finder_section.dart';
import '../../sections/image_section.dart';
import '../../sections/location_section.dart';
import '../../sections/rights_section.dart';
import '../../style.dart';
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
    final formKey = useRef(GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final totalAmount = useState(0);
    final imageFiles = useState<List<XFile>>([]);
    final selectedImages = useState<List<XFile>>([]);
    final showRightsOptions = useState(false);
    final showButtons = useState(true);

    // ScrollControllerの初期化と破棄を適切に管理
    final scrollController = useMemoized(() => ScrollController(), []);
    useEffect(() {
      return () {
        scrollController.dispose();
      };
    }, [scrollController]);

    final isInteracting = useState(false);
    final filledFields = useState<Set<String>>({});
    final isSubmitting = useState(false);

    // AnimationControllerの初期化
    final vsync = useSingleTickerProvider();
    final animationController = useMemoized(
      () => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: vsync,
      ),
      [vsync],
    );

    useEffect(() {
      return () {
        animationController.dispose();
      };
    }, [animationController]);

    final fadeAnimation = useMemoized(
      () => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      )),
      [animationController],
    );

    // フォーカス変更時のスクロール処理を定義
    void ensureFieldVisible(BuildContext fieldContext) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          fieldContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }

    // フォーカスノードの初期化
    final nodes = useMemoized(() {
      final createNode = (String fieldName) {
        final node = FocusNode();
        node.addListener(() {
          if (node.hasFocus && node.context != null) {
            ensureFieldVisible(node.context!);
          }
        });
        return node;
      };

      return {
        'itemName': createNode('itemName'),
        'itemDescription': createNode('itemDescription'),
        'foundDate': createNode('foundDate'),
        'foundTime': createNode('foundTime'),
        'locationPostalCode': createNode('locationPostalCode'),
        'locationAddress': createNode('locationAddress'),
        'routeName': createNode('routeName'),
        'vehicleNumber': createNode('vehicleNumber'),
        'finderName': createNode('finderName'),
        'finderContact': createNode('finderContact'),
        'finderPostalCode': createNode('finderPostalCode'),
        'finderAddress': createNode('finderAddress'),
      };
    }, []);

    // フォーカスノードの破棄を管理
    useEffect(() {
      return () {
        for (final node in nodes.values) {
          node.dispose();
        }
      };
    }, [nodes]);

    // フォームの値が変更されたときの処理
    void onFieldChanged(String fieldName, dynamic value) {
      if (value != null && value.toString().isNotEmpty) {
        filledFields.value = {...filledFields.value, fieldName};
      } else {
        filledFields.value = {...filledFields.value}..remove(fieldName);
      }

      // フォームの状態を更新
      if (formKey.value.currentState != null) {
        final currentField = formKey.value.currentState!.fields[fieldName];
        if (currentField != null && currentField.value != value) {
          currentField.didChange(value);
        }
      }
    }

    // 保存処理
    Future<void> saveDraft() async {
      if (formKey.value.currentState?.saveAndValidate() ?? false) {
        final formData =
            Map<String, dynamic>.from(formKey.value.currentState!.value);
        formData['cash'] = totalAmount.value;

        print('=== 保存するフォームデータ ===');
        print('編集モード: $isEditing');
        print('Draft ID: $draftId');
        print('フォームデータ: $formData');
        print('========================');

        try {
          isSaving.value = true;

          if (isEditing && draftId != null) {
            // 上書き保存
            print('上書き保存を実行');
            await ref
                .read(formViewModelProvider.notifier)
                .updateDraft(draftId!, formData);
            print('上書き保存完了');
          } else {
            // 新規の下書き保存
            print('新規保存を実行');
            await ref.read(formViewModelProvider.notifier).saveDraft(formData);
            print('新規保存完了');
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing ? '上書き保存しました' : '下書き保存しました'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );

            // 少し遅延させてから前の画面に戻る
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        } catch (e) {
          print('保存エラー: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('保存に失敗しました: $e'),
                backgroundColor: Colors.red,
              ),
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
        title: Text(
          isEditing ? '忘れ物情報編集' : '忘れ物情報登録',
          style: AppStyle.titleStyle,
        ),
      ),
      body: FormBuilder(
        key: formKey.value,
        initialValue: initialFormData ?? {},
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  initialImages: imageFiles.value,
                  onImagesChanged: (images) {
                    selectedImages.value = images;
                    formKey.value.currentState?.fields['images']
                        ?.didChange(images);
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        await saveDraft();
                      },
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  isEditing ? '上書き保存' : '下書き保存',
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSaving.value
                    ? null
                    : () {
                        onSubmit();
                      },
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  '確認',
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
