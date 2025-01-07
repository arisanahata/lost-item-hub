// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lost_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LostItemImpl _$$LostItemImplFromJson(Map<String, dynamic> json) =>
    _$LostItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      description: json['description'] as String?,
      needsReceipt: json['needsReceipt'] as bool,
      routeName: json['routeName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      otherLocation: json['otherLocation'] as String?,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      finderName: json['finderName'] as String,
      finderContact: json['finderContact'] as String?,
      finderPostalCode: json['finderPostalCode'] as String?,
      finderAddress: json['finderAddress'] as String?,
      cash: (json['cash'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LostItemImplToJson(_$LostItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'description': instance.description,
      'needsReceipt': instance.needsReceipt,
      'routeName': instance.routeName,
      'vehicleNumber': instance.vehicleNumber,
      'otherLocation': instance.otherLocation,
      'images': instance.images,
      'finderName': instance.finderName,
      'finderContact': instance.finderContact,
      'finderPostalCode': instance.finderPostalCode,
      'finderAddress': instance.finderAddress,
      'cash': instance.cash,
      'createdAt': instance.createdAt.toIso8601String(),
    };
