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

  factory LostItem.fromJson(Map<String, dynamic> json) => _$LostItemFromJson(json);
}
