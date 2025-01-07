// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entities/lost_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LostItem _$LostItemFromJson(Map<String, dynamic> json) {
  return _LostItem.fromJson(json);
}

/// @nodoc
mixin _$LostItem {
  String? get id => throw _privateConstructorUsedError; // 権利関係
  bool get hasRightsWaiver => throw _privateConstructorUsedError;
  bool get hasConsentToDisclose => throw _privateConstructorUsedError;
  List<String> get rightsOptions => throw _privateConstructorUsedError; // 拾得者情報
  String get finderName => throw _privateConstructorUsedError;
  String get finderAddress => throw _privateConstructorUsedError;
  String get finderPhone => throw _privateConstructorUsedError; // 基本情報
  DateTime get foundDate => throw _privateConstructorUsedError;
  String get foundTime => throw _privateConstructorUsedError;
  String get foundLocation => throw _privateConstructorUsedError;
  String get routeName => throw _privateConstructorUsedError;
  String? get vehicleNumber => throw _privateConstructorUsedError;
  List<String>? get imageUrls => throw _privateConstructorUsedError;
  String get itemColor => throw _privateConstructorUsedError;
  String get itemDescription => throw _privateConstructorUsedError;
  bool get needsReceipt => throw _privateConstructorUsedError; // 現金情報
  bool get hasCash => throw _privateConstructorUsedError;
  int get cash => throw _privateConstructorUsedError; // 合計金額
  int get yen10000 => throw _privateConstructorUsedError;
  int get yen5000 => throw _privateConstructorUsedError;
  int get yen2000 => throw _privateConstructorUsedError;
  int get yen1000 => throw _privateConstructorUsedError;
  int get yen500 => throw _privateConstructorUsedError;
  int get yen100 => throw _privateConstructorUsedError;
  int get yen50 => throw _privateConstructorUsedError;
  int get yen10 => throw _privateConstructorUsedError;
  int get yen5 => throw _privateConstructorUsedError;
  int get yen1 => throw _privateConstructorUsedError; // ステータス
  bool get isDraft => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LostItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LostItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LostItemCopyWith<LostItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LostItemCopyWith<$Res> {
  factory $LostItemCopyWith(LostItem value, $Res Function(LostItem) then) =
      _$LostItemCopyWithImpl<$Res, LostItem>;
  @useResult
  $Res call(
      {String? id,
      bool hasRightsWaiver,
      bool hasConsentToDisclose,
      List<String> rightsOptions,
      String finderName,
      String finderAddress,
      String finderPhone,
      DateTime foundDate,
      String foundTime,
      String foundLocation,
      String routeName,
      String? vehicleNumber,
      List<String>? imageUrls,
      String itemColor,
      String itemDescription,
      bool needsReceipt,
      bool hasCash,
      int cash,
      int yen10000,
      int yen5000,
      int yen2000,
      int yen1000,
      int yen500,
      int yen100,
      int yen50,
      int yen10,
      int yen5,
      int yen1,
      bool isDraft,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$LostItemCopyWithImpl<$Res, $Val extends LostItem>
    implements $LostItemCopyWith<$Res> {
  _$LostItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LostItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? hasRightsWaiver = null,
    Object? hasConsentToDisclose = null,
    Object? rightsOptions = null,
    Object? finderName = null,
    Object? finderAddress = null,
    Object? finderPhone = null,
    Object? foundDate = null,
    Object? foundTime = null,
    Object? foundLocation = null,
    Object? routeName = null,
    Object? vehicleNumber = freezed,
    Object? imageUrls = freezed,
    Object? itemColor = null,
    Object? itemDescription = null,
    Object? needsReceipt = null,
    Object? hasCash = null,
    Object? cash = null,
    Object? yen10000 = null,
    Object? yen5000 = null,
    Object? yen2000 = null,
    Object? yen1000 = null,
    Object? yen500 = null,
    Object? yen100 = null,
    Object? yen50 = null,
    Object? yen10 = null,
    Object? yen5 = null,
    Object? yen1 = null,
    Object? isDraft = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      hasRightsWaiver: null == hasRightsWaiver
          ? _value.hasRightsWaiver
          : hasRightsWaiver // ignore: cast_nullable_to_non_nullable
              as bool,
      hasConsentToDisclose: null == hasConsentToDisclose
          ? _value.hasConsentToDisclose
          : hasConsentToDisclose // ignore: cast_nullable_to_non_nullable
              as bool,
      rightsOptions: null == rightsOptions
          ? _value.rightsOptions
          : rightsOptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      finderName: null == finderName
          ? _value.finderName
          : finderName // ignore: cast_nullable_to_non_nullable
              as String,
      finderAddress: null == finderAddress
          ? _value.finderAddress
          : finderAddress // ignore: cast_nullable_to_non_nullable
              as String,
      finderPhone: null == finderPhone
          ? _value.finderPhone
          : finderPhone // ignore: cast_nullable_to_non_nullable
              as String,
      foundDate: null == foundDate
          ? _value.foundDate
          : foundDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      foundTime: null == foundTime
          ? _value.foundTime
          : foundTime // ignore: cast_nullable_to_non_nullable
              as String,
      foundLocation: null == foundLocation
          ? _value.foundLocation
          : foundLocation // ignore: cast_nullable_to_non_nullable
              as String,
      routeName: null == routeName
          ? _value.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNumber: freezed == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: freezed == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      itemColor: null == itemColor
          ? _value.itemColor
          : itemColor // ignore: cast_nullable_to_non_nullable
              as String,
      itemDescription: null == itemDescription
          ? _value.itemDescription
          : itemDescription // ignore: cast_nullable_to_non_nullable
              as String,
      needsReceipt: null == needsReceipt
          ? _value.needsReceipt
          : needsReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
      hasCash: null == hasCash
          ? _value.hasCash
          : hasCash // ignore: cast_nullable_to_non_nullable
              as bool,
      cash: null == cash
          ? _value.cash
          : cash // ignore: cast_nullable_to_non_nullable
              as int,
      yen10000: null == yen10000
          ? _value.yen10000
          : yen10000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen5000: null == yen5000
          ? _value.yen5000
          : yen5000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen2000: null == yen2000
          ? _value.yen2000
          : yen2000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen1000: null == yen1000
          ? _value.yen1000
          : yen1000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen500: null == yen500
          ? _value.yen500
          : yen500 // ignore: cast_nullable_to_non_nullable
              as int,
      yen100: null == yen100
          ? _value.yen100
          : yen100 // ignore: cast_nullable_to_non_nullable
              as int,
      yen50: null == yen50
          ? _value.yen50
          : yen50 // ignore: cast_nullable_to_non_nullable
              as int,
      yen10: null == yen10
          ? _value.yen10
          : yen10 // ignore: cast_nullable_to_non_nullable
              as int,
      yen5: null == yen5
          ? _value.yen5
          : yen5 // ignore: cast_nullable_to_non_nullable
              as int,
      yen1: null == yen1
          ? _value.yen1
          : yen1 // ignore: cast_nullable_to_non_nullable
              as int,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LostItemImplCopyWith<$Res>
    implements $LostItemCopyWith<$Res> {
  factory _$$LostItemImplCopyWith(
          _$LostItemImpl value, $Res Function(_$LostItemImpl) then) =
      __$$LostItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      bool hasRightsWaiver,
      bool hasConsentToDisclose,
      List<String> rightsOptions,
      String finderName,
      String finderAddress,
      String finderPhone,
      DateTime foundDate,
      String foundTime,
      String foundLocation,
      String routeName,
      String? vehicleNumber,
      List<String>? imageUrls,
      String itemColor,
      String itemDescription,
      bool needsReceipt,
      bool hasCash,
      int cash,
      int yen10000,
      int yen5000,
      int yen2000,
      int yen1000,
      int yen500,
      int yen100,
      int yen50,
      int yen10,
      int yen5,
      int yen1,
      bool isDraft,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$LostItemImplCopyWithImpl<$Res>
    extends _$LostItemCopyWithImpl<$Res, _$LostItemImpl>
    implements _$$LostItemImplCopyWith<$Res> {
  __$$LostItemImplCopyWithImpl(
      _$LostItemImpl _value, $Res Function(_$LostItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of LostItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? hasRightsWaiver = null,
    Object? hasConsentToDisclose = null,
    Object? rightsOptions = null,
    Object? finderName = null,
    Object? finderAddress = null,
    Object? finderPhone = null,
    Object? foundDate = null,
    Object? foundTime = null,
    Object? foundLocation = null,
    Object? routeName = null,
    Object? vehicleNumber = freezed,
    Object? imageUrls = freezed,
    Object? itemColor = null,
    Object? itemDescription = null,
    Object? needsReceipt = null,
    Object? hasCash = null,
    Object? cash = null,
    Object? yen10000 = null,
    Object? yen5000 = null,
    Object? yen2000 = null,
    Object? yen1000 = null,
    Object? yen500 = null,
    Object? yen100 = null,
    Object? yen50 = null,
    Object? yen10 = null,
    Object? yen5 = null,
    Object? yen1 = null,
    Object? isDraft = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$LostItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      hasRightsWaiver: null == hasRightsWaiver
          ? _value.hasRightsWaiver
          : hasRightsWaiver // ignore: cast_nullable_to_non_nullable
              as bool,
      hasConsentToDisclose: null == hasConsentToDisclose
          ? _value.hasConsentToDisclose
          : hasConsentToDisclose // ignore: cast_nullable_to_non_nullable
              as bool,
      rightsOptions: null == rightsOptions
          ? _value._rightsOptions
          : rightsOptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      finderName: null == finderName
          ? _value.finderName
          : finderName // ignore: cast_nullable_to_non_nullable
              as String,
      finderAddress: null == finderAddress
          ? _value.finderAddress
          : finderAddress // ignore: cast_nullable_to_non_nullable
              as String,
      finderPhone: null == finderPhone
          ? _value.finderPhone
          : finderPhone // ignore: cast_nullable_to_non_nullable
              as String,
      foundDate: null == foundDate
          ? _value.foundDate
          : foundDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      foundTime: null == foundTime
          ? _value.foundTime
          : foundTime // ignore: cast_nullable_to_non_nullable
              as String,
      foundLocation: null == foundLocation
          ? _value.foundLocation
          : foundLocation // ignore: cast_nullable_to_non_nullable
              as String,
      routeName: null == routeName
          ? _value.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNumber: freezed == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: freezed == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      itemColor: null == itemColor
          ? _value.itemColor
          : itemColor // ignore: cast_nullable_to_non_nullable
              as String,
      itemDescription: null == itemDescription
          ? _value.itemDescription
          : itemDescription // ignore: cast_nullable_to_non_nullable
              as String,
      needsReceipt: null == needsReceipt
          ? _value.needsReceipt
          : needsReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
      hasCash: null == hasCash
          ? _value.hasCash
          : hasCash // ignore: cast_nullable_to_non_nullable
              as bool,
      cash: null == cash
          ? _value.cash
          : cash // ignore: cast_nullable_to_non_nullable
              as int,
      yen10000: null == yen10000
          ? _value.yen10000
          : yen10000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen5000: null == yen5000
          ? _value.yen5000
          : yen5000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen2000: null == yen2000
          ? _value.yen2000
          : yen2000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen1000: null == yen1000
          ? _value.yen1000
          : yen1000 // ignore: cast_nullable_to_non_nullable
              as int,
      yen500: null == yen500
          ? _value.yen500
          : yen500 // ignore: cast_nullable_to_non_nullable
              as int,
      yen100: null == yen100
          ? _value.yen100
          : yen100 // ignore: cast_nullable_to_non_nullable
              as int,
      yen50: null == yen50
          ? _value.yen50
          : yen50 // ignore: cast_nullable_to_non_nullable
              as int,
      yen10: null == yen10
          ? _value.yen10
          : yen10 // ignore: cast_nullable_to_non_nullable
              as int,
      yen5: null == yen5
          ? _value.yen5
          : yen5 // ignore: cast_nullable_to_non_nullable
              as int,
      yen1: null == yen1
          ? _value.yen1
          : yen1 // ignore: cast_nullable_to_non_nullable
              as int,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LostItemImpl implements _LostItem {
  const _$LostItemImpl(
      {this.id,
      required this.hasRightsWaiver,
      required this.hasConsentToDisclose,
      final List<String> rightsOptions = const [],
      required this.finderName,
      required this.finderAddress,
      required this.finderPhone,
      required this.foundDate,
      required this.foundTime,
      required this.foundLocation,
      required this.routeName,
      this.vehicleNumber,
      final List<String>? imageUrls,
      required this.itemColor,
      required this.itemDescription,
      required this.needsReceipt,
      this.hasCash = false,
      this.cash = 0,
      this.yen10000 = 0,
      this.yen5000 = 0,
      this.yen2000 = 0,
      this.yen1000 = 0,
      this.yen500 = 0,
      this.yen100 = 0,
      this.yen50 = 0,
      this.yen10 = 0,
      this.yen5 = 0,
      this.yen1 = 0,
      this.isDraft = false,
      this.createdAt,
      this.updatedAt})
      : _rightsOptions = rightsOptions,
        _imageUrls = imageUrls;

  factory _$LostItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LostItemImplFromJson(json);

  @override
  final String? id;
// 権利関係
  @override
  final bool hasRightsWaiver;
  @override
  final bool hasConsentToDisclose;
  final List<String> _rightsOptions;
  @override
  @JsonKey()
  List<String> get rightsOptions {
    if (_rightsOptions is EqualUnmodifiableListView) return _rightsOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rightsOptions);
  }

// 拾得者情報
  @override
  final String finderName;
  @override
  final String finderAddress;
  @override
  final String finderPhone;
// 基本情報
  @override
  final DateTime foundDate;
  @override
  final String foundTime;
  @override
  final String foundLocation;
  @override
  final String routeName;
  @override
  final String? vehicleNumber;
  final List<String>? _imageUrls;
  @override
  List<String>? get imageUrls {
    final value = _imageUrls;
    if (value == null) return null;
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String itemColor;
  @override
  final String itemDescription;
  @override
  final bool needsReceipt;
// 現金情報
  @override
  @JsonKey()
  final bool hasCash;
  @override
  @JsonKey()
  final int cash;
// 合計金額
  @override
  @JsonKey()
  final int yen10000;
  @override
  @JsonKey()
  final int yen5000;
  @override
  @JsonKey()
  final int yen2000;
  @override
  @JsonKey()
  final int yen1000;
  @override
  @JsonKey()
  final int yen500;
  @override
  @JsonKey()
  final int yen100;
  @override
  @JsonKey()
  final int yen50;
  @override
  @JsonKey()
  final int yen10;
  @override
  @JsonKey()
  final int yen5;
  @override
  @JsonKey()
  final int yen1;
// ステータス
  @override
  @JsonKey()
  final bool isDraft;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LostItem(id: $id, hasRightsWaiver: $hasRightsWaiver, hasConsentToDisclose: $hasConsentToDisclose, rightsOptions: $rightsOptions, finderName: $finderName, finderAddress: $finderAddress, finderPhone: $finderPhone, foundDate: $foundDate, foundTime: $foundTime, foundLocation: $foundLocation, routeName: $routeName, vehicleNumber: $vehicleNumber, imageUrls: $imageUrls, itemColor: $itemColor, itemDescription: $itemDescription, needsReceipt: $needsReceipt, hasCash: $hasCash, cash: $cash, yen10000: $yen10000, yen5000: $yen5000, yen2000: $yen2000, yen1000: $yen1000, yen500: $yen500, yen100: $yen100, yen50: $yen50, yen10: $yen10, yen5: $yen5, yen1: $yen1, isDraft: $isDraft, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LostItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hasRightsWaiver, hasRightsWaiver) ||
                other.hasRightsWaiver == hasRightsWaiver) &&
            (identical(other.hasConsentToDisclose, hasConsentToDisclose) ||
                other.hasConsentToDisclose == hasConsentToDisclose) &&
            const DeepCollectionEquality()
                .equals(other._rightsOptions, _rightsOptions) &&
            (identical(other.finderName, finderName) ||
                other.finderName == finderName) &&
            (identical(other.finderAddress, finderAddress) ||
                other.finderAddress == finderAddress) &&
            (identical(other.finderPhone, finderPhone) ||
                other.finderPhone == finderPhone) &&
            (identical(other.foundDate, foundDate) ||
                other.foundDate == foundDate) &&
            (identical(other.foundTime, foundTime) ||
                other.foundTime == foundTime) &&
            (identical(other.foundLocation, foundLocation) ||
                other.foundLocation == foundLocation) &&
            (identical(other.routeName, routeName) ||
                other.routeName == routeName) &&
            (identical(other.vehicleNumber, vehicleNumber) ||
                other.vehicleNumber == vehicleNumber) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.itemColor, itemColor) ||
                other.itemColor == itemColor) &&
            (identical(other.itemDescription, itemDescription) ||
                other.itemDescription == itemDescription) &&
            (identical(other.needsReceipt, needsReceipt) ||
                other.needsReceipt == needsReceipt) &&
            (identical(other.hasCash, hasCash) || other.hasCash == hasCash) &&
            (identical(other.cash, cash) || other.cash == cash) &&
            (identical(other.yen10000, yen10000) ||
                other.yen10000 == yen10000) &&
            (identical(other.yen5000, yen5000) || other.yen5000 == yen5000) &&
            (identical(other.yen2000, yen2000) || other.yen2000 == yen2000) &&
            (identical(other.yen1000, yen1000) || other.yen1000 == yen1000) &&
            (identical(other.yen500, yen500) || other.yen500 == yen500) &&
            (identical(other.yen100, yen100) || other.yen100 == yen100) &&
            (identical(other.yen50, yen50) || other.yen50 == yen50) &&
            (identical(other.yen10, yen10) || other.yen10 == yen10) &&
            (identical(other.yen5, yen5) || other.yen5 == yen5) &&
            (identical(other.yen1, yen1) || other.yen1 == yen1) &&
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        hasRightsWaiver,
        hasConsentToDisclose,
        const DeepCollectionEquality().hash(_rightsOptions),
        finderName,
        finderAddress,
        finderPhone,
        foundDate,
        foundTime,
        foundLocation,
        routeName,
        vehicleNumber,
        const DeepCollectionEquality().hash(_imageUrls),
        itemColor,
        itemDescription,
        needsReceipt,
        hasCash,
        cash,
        yen10000,
        yen5000,
        yen2000,
        yen1000,
        yen500,
        yen100,
        yen50,
        yen10,
        yen5,
        yen1,
        isDraft,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of LostItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LostItemImplCopyWith<_$LostItemImpl> get copyWith =>
      __$$LostItemImplCopyWithImpl<_$LostItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LostItemImplToJson(
      this,
    );
  }
}

abstract class _LostItem implements LostItem {
  const factory _LostItem(
      {final String? id,
      required final bool hasRightsWaiver,
      required final bool hasConsentToDisclose,
      final List<String> rightsOptions,
      required final String finderName,
      required final String finderAddress,
      required final String finderPhone,
      required final DateTime foundDate,
      required final String foundTime,
      required final String foundLocation,
      required final String routeName,
      final String? vehicleNumber,
      final List<String>? imageUrls,
      required final String itemColor,
      required final String itemDescription,
      required final bool needsReceipt,
      final bool hasCash,
      final int cash,
      final int yen10000,
      final int yen5000,
      final int yen2000,
      final int yen1000,
      final int yen500,
      final int yen100,
      final int yen50,
      final int yen10,
      final int yen5,
      final int yen1,
      final bool isDraft,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$LostItemImpl;

  factory _LostItem.fromJson(Map<String, dynamic> json) =
      _$LostItemImpl.fromJson;

  @override
  String? get id; // 権利関係
  @override
  bool get hasRightsWaiver;
  @override
  bool get hasConsentToDisclose;
  @override
  List<String> get rightsOptions; // 拾得者情報
  @override
  String get finderName;
  @override
  String get finderAddress;
  @override
  String get finderPhone; // 基本情報
  @override
  DateTime get foundDate;
  @override
  String get foundTime;
  @override
  String get foundLocation;
  @override
  String get routeName;
  @override
  String? get vehicleNumber;
  @override
  List<String>? get imageUrls;
  @override
  String get itemColor;
  @override
  String get itemDescription;
  @override
  bool get needsReceipt; // 現金情報
  @override
  bool get hasCash;
  @override
  int get cash; // 合計金額
  @override
  int get yen10000;
  @override
  int get yen5000;
  @override
  int get yen2000;
  @override
  int get yen1000;
  @override
  int get yen500;
  @override
  int get yen100;
  @override
  int get yen50;
  @override
  int get yen10;
  @override
  int get yen5;
  @override
  int get yen1; // ステータス
  @override
  bool get isDraft;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of LostItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LostItemImplCopyWith<_$LostItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
