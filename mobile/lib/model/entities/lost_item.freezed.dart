// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lost_item.dart';

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
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get needsReceipt => throw _privateConstructorUsedError;
  String get routeName => throw _privateConstructorUsedError;
  String get vehicleNumber => throw _privateConstructorUsedError;
  String? get otherLocation => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String get finderName => throw _privateConstructorUsedError;
  String? get finderContact => throw _privateConstructorUsedError;
  String? get finderPostalCode => throw _privateConstructorUsedError;
  String? get finderAddress => throw _privateConstructorUsedError;
  int? get cash => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

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
      {String id,
      String name,
      String? color,
      String? description,
      bool needsReceipt,
      String routeName,
      String vehicleNumber,
      String? otherLocation,
      List<String> images,
      String finderName,
      String? finderContact,
      String? finderPostalCode,
      String? finderAddress,
      int? cash,
      DateTime createdAt});
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
    Object? id = null,
    Object? name = null,
    Object? color = freezed,
    Object? description = freezed,
    Object? needsReceipt = null,
    Object? routeName = null,
    Object? vehicleNumber = null,
    Object? otherLocation = freezed,
    Object? images = null,
    Object? finderName = null,
    Object? finderContact = freezed,
    Object? finderPostalCode = freezed,
    Object? finderAddress = freezed,
    Object? cash = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      needsReceipt: null == needsReceipt
          ? _value.needsReceipt
          : needsReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
      routeName: null == routeName
          ? _value.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNumber: null == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String,
      otherLocation: freezed == otherLocation
          ? _value.otherLocation
          : otherLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      finderName: null == finderName
          ? _value.finderName
          : finderName // ignore: cast_nullable_to_non_nullable
              as String,
      finderContact: freezed == finderContact
          ? _value.finderContact
          : finderContact // ignore: cast_nullable_to_non_nullable
              as String?,
      finderPostalCode: freezed == finderPostalCode
          ? _value.finderPostalCode
          : finderPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      finderAddress: freezed == finderAddress
          ? _value.finderAddress
          : finderAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      cash: freezed == cash
          ? _value.cash
          : cash // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      {String id,
      String name,
      String? color,
      String? description,
      bool needsReceipt,
      String routeName,
      String vehicleNumber,
      String? otherLocation,
      List<String> images,
      String finderName,
      String? finderContact,
      String? finderPostalCode,
      String? finderAddress,
      int? cash,
      DateTime createdAt});
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
    Object? id = null,
    Object? name = null,
    Object? color = freezed,
    Object? description = freezed,
    Object? needsReceipt = null,
    Object? routeName = null,
    Object? vehicleNumber = null,
    Object? otherLocation = freezed,
    Object? images = null,
    Object? finderName = null,
    Object? finderContact = freezed,
    Object? finderPostalCode = freezed,
    Object? finderAddress = freezed,
    Object? cash = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$LostItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      needsReceipt: null == needsReceipt
          ? _value.needsReceipt
          : needsReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
      routeName: null == routeName
          ? _value.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNumber: null == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String,
      otherLocation: freezed == otherLocation
          ? _value.otherLocation
          : otherLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      finderName: null == finderName
          ? _value.finderName
          : finderName // ignore: cast_nullable_to_non_nullable
              as String,
      finderContact: freezed == finderContact
          ? _value.finderContact
          : finderContact // ignore: cast_nullable_to_non_nullable
              as String?,
      finderPostalCode: freezed == finderPostalCode
          ? _value.finderPostalCode
          : finderPostalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      finderAddress: freezed == finderAddress
          ? _value.finderAddress
          : finderAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      cash: freezed == cash
          ? _value.cash
          : cash // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LostItemImpl implements _LostItem {
  const _$LostItemImpl(
      {required this.id,
      required this.name,
      this.color,
      this.description,
      required this.needsReceipt,
      required this.routeName,
      required this.vehicleNumber,
      this.otherLocation,
      required final List<String> images,
      required this.finderName,
      this.finderContact,
      this.finderPostalCode,
      this.finderAddress,
      this.cash,
      required this.createdAt})
      : _images = images;

  factory _$LostItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LostItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? color;
  @override
  final String? description;
  @override
  final bool needsReceipt;
  @override
  final String routeName;
  @override
  final String vehicleNumber;
  @override
  final String? otherLocation;
  final List<String> _images;
  @override
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String finderName;
  @override
  final String? finderContact;
  @override
  final String? finderPostalCode;
  @override
  final String? finderAddress;
  @override
  final int? cash;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LostItem(id: $id, name: $name, color: $color, description: $description, needsReceipt: $needsReceipt, routeName: $routeName, vehicleNumber: $vehicleNumber, otherLocation: $otherLocation, images: $images, finderName: $finderName, finderContact: $finderContact, finderPostalCode: $finderPostalCode, finderAddress: $finderAddress, cash: $cash, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LostItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.needsReceipt, needsReceipt) ||
                other.needsReceipt == needsReceipt) &&
            (identical(other.routeName, routeName) ||
                other.routeName == routeName) &&
            (identical(other.vehicleNumber, vehicleNumber) ||
                other.vehicleNumber == vehicleNumber) &&
            (identical(other.otherLocation, otherLocation) ||
                other.otherLocation == otherLocation) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.finderName, finderName) ||
                other.finderName == finderName) &&
            (identical(other.finderContact, finderContact) ||
                other.finderContact == finderContact) &&
            (identical(other.finderPostalCode, finderPostalCode) ||
                other.finderPostalCode == finderPostalCode) &&
            (identical(other.finderAddress, finderAddress) ||
                other.finderAddress == finderAddress) &&
            (identical(other.cash, cash) || other.cash == cash) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      color,
      description,
      needsReceipt,
      routeName,
      vehicleNumber,
      otherLocation,
      const DeepCollectionEquality().hash(_images),
      finderName,
      finderContact,
      finderPostalCode,
      finderAddress,
      cash,
      createdAt);

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
      {required final String id,
      required final String name,
      final String? color,
      final String? description,
      required final bool needsReceipt,
      required final String routeName,
      required final String vehicleNumber,
      final String? otherLocation,
      required final List<String> images,
      required final String finderName,
      final String? finderContact,
      final String? finderPostalCode,
      final String? finderAddress,
      final int? cash,
      required final DateTime createdAt}) = _$LostItemImpl;

  factory _LostItem.fromJson(Map<String, dynamic> json) =
      _$LostItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get color;
  @override
  String? get description;
  @override
  bool get needsReceipt;
  @override
  String get routeName;
  @override
  String get vehicleNumber;
  @override
  String? get otherLocation;
  @override
  List<String> get images;
  @override
  String get finderName;
  @override
  String? get finderContact;
  @override
  String? get finderPostalCode;
  @override
  String? get finderAddress;
  @override
  int? get cash;
  @override
  DateTime get createdAt;

  /// Create a copy of LostItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LostItemImplCopyWith<_$LostItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
