import 'package:freezed_annotation/freezed_annotation.dart';

part 'lost_item.freezed.dart';
part 'lost_item.g.dart';

@freezed
class LostItem with _$LostItem {
  const factory LostItem({
    required String id,
    required String name,
    String? color,
    String? description,
    required bool needsReceipt,
    required String routeName,
    required String vehicleNumber,
    String? otherLocation,
    required List<String> images,
    required String finderName,
    String? finderContact,
    String? finderPostalCode,
    String? finderAddress,
    int? cash,
    required DateTime createdAt,
  }) = _LostItem;

  factory LostItem.fromJson(Map<String, dynamic> json) =>
      _$LostItemFromJson(json);
}
