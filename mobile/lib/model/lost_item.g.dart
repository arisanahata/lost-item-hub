// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lost_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LostItemImpl _$$LostItemImplFromJson(Map<String, dynamic> json) =>
    _$LostItemImpl(
      id: json['id'] as String?,
      hasRightsWaiver: json['hasRightsWaiver'] as bool,
      hasConsentToDisclose: json['hasConsentToDisclose'] as bool,
      rightsOptions: (json['rightsOptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      finderName: json['finderName'] as String,
      finderAddress: json['finderAddress'] as String,
      finderPhone: json['finderPhone'] as String,
      foundDate: DateTime.parse(json['foundDate'] as String),
      foundTime: json['foundTime'] as String,
      foundLocation: json['foundLocation'] as String,
      routeName: json['routeName'] as String,
      vehicleNumber: json['vehicleNumber'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      itemColor: json['itemColor'] as String,
      itemDescription: json['itemDescription'] as String,
      needsReceipt: json['needsReceipt'] as bool,
      hasCash: json['hasCash'] as bool? ?? false,
      cash: (json['cash'] as num?)?.toInt() ?? 0,
      yen10000: (json['yen10000'] as num?)?.toInt() ?? 0,
      yen5000: (json['yen5000'] as num?)?.toInt() ?? 0,
      yen2000: (json['yen2000'] as num?)?.toInt() ?? 0,
      yen1000: (json['yen1000'] as num?)?.toInt() ?? 0,
      yen500: (json['yen500'] as num?)?.toInt() ?? 0,
      yen100: (json['yen100'] as num?)?.toInt() ?? 0,
      yen50: (json['yen50'] as num?)?.toInt() ?? 0,
      yen10: (json['yen10'] as num?)?.toInt() ?? 0,
      yen5: (json['yen5'] as num?)?.toInt() ?? 0,
      yen1: (json['yen1'] as num?)?.toInt() ?? 0,
      isDraft: json['isDraft'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LostItemImplToJson(_$LostItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hasRightsWaiver': instance.hasRightsWaiver,
      'hasConsentToDisclose': instance.hasConsentToDisclose,
      'rightsOptions': instance.rightsOptions,
      'finderName': instance.finderName,
      'finderAddress': instance.finderAddress,
      'finderPhone': instance.finderPhone,
      'foundDate': instance.foundDate.toIso8601String(),
      'foundTime': instance.foundTime,
      'foundLocation': instance.foundLocation,
      'routeName': instance.routeName,
      'vehicleNumber': instance.vehicleNumber,
      'imageUrls': instance.imageUrls,
      'itemColor': instance.itemColor,
      'itemDescription': instance.itemDescription,
      'needsReceipt': instance.needsReceipt,
      'hasCash': instance.hasCash,
      'cash': instance.cash,
      'yen10000': instance.yen10000,
      'yen5000': instance.yen5000,
      'yen2000': instance.yen2000,
      'yen1000': instance.yen1000,
      'yen500': instance.yen500,
      'yen100': instance.yen100,
      'yen50': instance.yen50,
      'yen10': instance.yen10,
      'yen5': instance.yen5,
      'yen1': instance.yen1,
      'isDraft': instance.isDraft,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
