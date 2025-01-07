import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // import追加
import '../../../model/draft_item.dart';
import '../../../model/repository/image_repository.dart';
import '../../../model/stored_image.dart';
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
    final formKey = useState(GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final totalAmount = useState(0);
    final selectedImages = useState<List<XFile>>([]);
    final storedImages = useState<List<StoredImage>>([]);
    final showRightsOptions = useState(false);
    final showButtons = useState(true);
    final isInteracting = useState(false);
    final filledFields = useState<Set<String>>({});
    final isSubmitting = useState(false);

    // ScrollControllerの初期化と破棄を適切に管理
    final scrollController = useMemoized(() => ScrollController(), []);
    useEffect(() {
      return () {
        scrollController.dispose();
      };
    }, [scrollController]);

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

    // 初期データの読み込み
    useEffect(() {
      if (initialFormData != null) {
        print('LostItemFormScreen - 初期データを読み込み:');

        // フォームデータの設定
        formKey.value.currentState?.patchValue({
          ...initialFormData!,
        });

        // 画像の読み込み
        if (isEditing && initialFormData!['draft'] != null) {
          final draft = initialFormData!['draft'] as DraftItem;
          if (draft.imagePaths != null && draft.imagePaths!.isNotEmpty) {
            print('  画像の読み込みを開始: ${draft.imagePaths!.length}枚');
            ref
                .read(formViewModelProvider.notifier)
                .loadImages(draft.imagePaths!)
                .then((loadedImages) {
              if (loadedImages.isNotEmpty) {
                storedImages.value = loadedImages;
                print('  画像の読み込み完了: ${loadedImages.length}枚');
              }
            });
          }
        }
      }
      return null;
    }, [initialFormData]);

    void onFieldChanged(String fieldName, dynamic value) {
      print('LostItemFormScreen - フィールドが変更されました:');
      print('  フィールド名: $fieldName');
      print('  値: $value');

      if (value != null) {
        // build中のsetStateを避けるために遅延実行
        Future.microtask(() {
          if (fieldName == 'images') {
            print('  画像データを更新: ${(value as List<XFile>).length}枚');
            selectedImages.value = List<XFile>.from(value);
          } else {
            filledFields.value = {...filledFields.value, fieldName};
            final currentValue =
                formKey.value.currentState?.fields[fieldName]?.value;
            if (currentValue != value) {
              print('  フォームの値を更新: $value (現在の値: $currentValue)');
              formKey.value.currentState?.fields[fieldName]?.didChange(value);
            } else {
              print('  フォームの値は既に最新: $value');
            }
          }
        });
      } else {
        Future.microtask(() {
          filledFields.value = {...filledFields.value}..remove(fieldName);
          print('  フィールドを削除: $fieldName');
        });
      }
    }

    void onStoredImagesChanged(List<StoredImage> images) {
      print('LostItemFormScreen - 保存済みの画像が変更されました:');
      print('  画像数: ${images.length}枚');
      storedImages.value = images;
    }

    // 保存処理
    Future<void> saveDraft() async {
      if (formKey.value.currentState?.saveAndValidate() ?? false) {
        try {
          isSaving.value = true;
          final formData =
              Map<String, dynamic>.from(formKey.value.currentState!.value);

          print('\n  現金データの処理:');
          final cash = formData['cash'];
          print('    取得した値: $cash');
          if (cash == 0) {
            formData.remove('cash');
            print('    現金データを削除');
          }

          print('\n  画像データの処理:');
          final selectedImagePaths =
              selectedImages.value.map((file) => file.path).toList();
          final storedImagePaths =
              storedImages.value.map((image) => image.id).toList();
          final allImagePaths = [...storedImagePaths, ...selectedImagePaths];

          print('    選択された画像: ${selectedImagePaths.length}枚');
          print('    保存済みの画像: ${storedImagePaths.length}枚');
          print('    保存する画像: ${allImagePaths.length}枚');
          print('    画像パス: $allImagePaths');

          if (isEditing && draftId != null) {
            // 上書き保存
            print('上書き保存を実行');
            await ref
                .read(formViewModelProvider.notifier)
                .saveDraft(formData, allImagePaths, draftId: draftId);
            print('上書き保存完了');
          } else {
            // 新規の下書き保存
            print('新規保存を実行');
            await ref
                .read(formViewModelProvider.notifier)
                .saveDraft(formData, allImagePaths);
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
          final formData = Map<String, dynamic>.from(formKey.value.currentState!.value);
          
          // 画像データを追加
          final storedImageIds = storedImages.value.map((image) => image.id).toList();
          formData['images'] = storedImageIds;
          
          print('確認画面に遷移:');
          print('  フォームデータ: $formData');
          print('  画像データ: $storedImageIds');

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LostItemConfirmScreen(
                formData: formData,
                draftId: draftId,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } finally {
          isSubmitting.value = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '下書きを編集' : '新規登録'),
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
                  initialImages: storedImages.value,
                  onImagesChanged: (images) {
                    selectedImages.value = images;
                  },
                  onStoredImagesChanged: (images) {
                    storedImages.value = images;
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
