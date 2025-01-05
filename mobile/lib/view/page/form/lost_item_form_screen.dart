import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../util/image_storage.dart';
import '../../../viewmodel/form_viewmodel.dart';
import '../../component/money_input.dart';
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
    final selectedImages = useState<List<XFile>>([]);
    final showRightsOptions = useState(false);
    final showButtons = useState(true);

    // 初期画像の読み込み
    useEffect(() {
      if (initialFormData != null && initialFormData!['imagePaths'] != null) {
        Future.microtask(() async {
          final imagePaths = List<String>.from(initialFormData!['imagePaths']);
          final images = await ImageStorage.pathsToXFiles(imagePaths);
          selectedImages.value = images;
        });
      }
      return null;
    }, []);

    // ScrollControllerの初期化と破棄を適切に管理
    final scrollController = useMemoized(() => ScrollController(), []);
    useEffect(() {
      return () {
        scrollController.dispose();
      };
    }, [scrollController]);

    final isInteracting = useState(false);
    final filledFields = useState<Set<String>>({});

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
      print('LostItemFormScreen - フィールドが変更されました:');
      print('  フィールド名: $fieldName');
      print('  値: $value');
      
      if (value != null) {
        // build中のsetStateを避けるために遅延実行
        Future.microtask(() {
          filledFields.value = {...filledFields.value, fieldName};
          // フォームの状態を更新
          if (formKey.value.currentState?.fields[fieldName] != null) {
            print('  フォームの値を更新: $value');
            formKey.value.currentState?.fields[fieldName]?.didChange(value);
          } else {
            print('  フィールドが見つかりません: $fieldName');
          }
        });
      } else {
        Future.microtask(() {
          filledFields.value = {...filledFields.value}..remove(fieldName);
          print('  フィールドを削除: $fieldName');
        });
      }
    }

    // 保存処理
    Future<void> saveDraft() async {
      print('\nLostItemFormScreen - 保存処理を開始');
      if (formKey.value.currentState?.saveAndValidate() ?? false) {
        print('  フォームのバリデーションが成功');
        final formData =
            Map<String, dynamic>.from(formKey.value.currentState!.value);
        
        print('  フォームの全データ:');
        formData.forEach((key, value) {
          print('    $key: $value');
        });

        // 現金データを追加（フォームから取得）
        final cashValue = formData['cash'] as int?;
        print('\n  現金データの処理:');
        print('    取得した値: $cashValue');
        
        if (cashValue != null && cashValue > 0) {
          formData['cash'] = cashValue;
          print('    保存する金額: $cashValue');
        } else {
          print('    現金データは保存しません');
        }

        // 画像データを追加
        formData['images'] = selectedImages.value;

        print('\n=== 保存するフォームデータ ===');
        print('編集モード: $isEditing');
        print('Draft ID: $draftId');
        print('現金: ${formData['cash'] ?? 0}円');
        print('フォームデータ: $formData');
        print('画像枚数: ${selectedImages.value.length}');
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
        try {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LostItemConfirmScreen(
                formData: formKey.value.currentState!.value,
                draftId: draftId,
              ),
            ),
          );
        } finally {}
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
                  totalAmount: totalAmount,
                ),
                ImageSection(
                  initialImages: selectedImages.value,
                  onImagesChanged: (images) {
                    selectedImages.value = images;
                    onFieldChanged('images', images);
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
