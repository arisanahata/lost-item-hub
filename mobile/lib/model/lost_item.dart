import 'package:freezed_annotation/freezed_annotation.dart';

part 'lost_item.freezed.dart';
part 'lost_item.g.dart';

@freezed
class LostItem with _$LostItem {
  const factory LostItem({
    String? id,
    // 権利関係
    required bool hasRightsWaiver,
    required bool hasConsentToDisclose,
    @Default([]) List<String> rightsOptions,

    // 拾得者情報
    required String finderName,
    required String finderAddress,
    required String finderPhone,

    // 基本情報
    required DateTime foundDate,
    required String foundTime,
    required String foundLocation,
    required String routeName,
    String? vehicleNumber,
    List<String>? imageUrls,
    required String itemColor,
    required String itemDescription,
    required bool needsReceipt,

    // 現金情報
    @Default(false) bool hasCash,
    @Default(0) int cash, // 合計金額
    @Default(0) int yen10000,
    @Default(0) int yen5000,
    @Default(0) int yen2000,
    @Default(0) int yen1000,
    @Default(0) int yen500,
    @Default(0) int yen100,
    @Default(0) int yen50,
    @Default(0) int yen10,
    @Default(0) int yen5,
    @Default(0) int yen1,

    // ステータス
    @Default(false) bool isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LostItem;

  factory LostItem.fromJson(Map<String, dynamic> json) =>
      _$LostItemFromJson(json);

  factory LostItem.fromFormData(Map<String, dynamic> formData) {
    return LostItem(
      hasRightsWaiver: formData['hasRightsWaiver'] ?? false,
      hasConsentToDisclose: formData['hasConsentToDisclose'] ?? false,
      rightsOptions: List<String>.from(formData['rightsOptions'] ?? []),
      finderName: formData['finderName'] ?? '',
      finderAddress: formData['finderAddress'] ?? '',
      finderPhone: formData['finderPhone'] ?? '',
      foundDate: DateTime.parse(
          formData['foundDate'] ?? DateTime.now().toIso8601String()),
      foundTime: formData['foundTime'] ?? '',
      foundLocation: formData['foundLocation'] ?? '',
      routeName: formData['routeName'] ?? '',
      vehicleNumber: formData['vehicleNumber'],
      imageUrls: List<String>.from(formData['imageUrls'] ?? []),
      itemColor: formData['itemColor'] ?? '',
      itemDescription: formData['itemDescription'] ?? '',
      needsReceipt: formData['needsReceipt'] ?? false,
      hasCash: formData['hasCash'] ?? false,
      cash: int.tryParse(formData['cash']?.toString() ?? '0') ?? 0,
      yen10000: int.tryParse(formData['yen10000']?.toString() ?? '0') ?? 0,
      yen5000: int.tryParse(formData['yen5000']?.toString() ?? '0') ?? 0,
      yen2000: int.tryParse(formData['yen2000']?.toString() ?? '0') ?? 0,
      yen1000: int.tryParse(formData['yen1000']?.toString() ?? '0') ?? 0,
      yen500: int.tryParse(formData['yen500']?.toString() ?? '0') ?? 0,
      yen100: int.tryParse(formData['yen100']?.toString() ?? '0') ?? 0,
      yen50: int.tryParse(formData['yen50']?.toString() ?? '0') ?? 0,
      yen10: int.tryParse(formData['yen10']?.toString() ?? '0') ?? 0,
      yen5: int.tryParse(formData['yen5']?.toString() ?? '0') ?? 0,
      yen1: int.tryParse(formData['yen1']?.toString() ?? '0') ?? 0,
    );
  }
}
