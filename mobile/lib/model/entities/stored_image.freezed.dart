// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stored_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StoredImage _$StoredImageFromJson(Map<String, dynamic> json) {
  return _StoredImage.fromJson(json);
}

/// @nodoc
mixin _$StoredImage {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get filePath => throw _privateConstructorUsedError;
  @HiveField(2)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StoredImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoredImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoredImageCopyWith<StoredImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoredImageCopyWith<$Res> {
  factory $StoredImageCopyWith(
          StoredImage value, $Res Function(StoredImage) then) =
      _$StoredImageCopyWithImpl<$Res, StoredImage>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String filePath,
      @HiveField(2) DateTime createdAt});
}

/// @nodoc
class _$StoredImageCopyWithImpl<$Res, $Val extends StoredImage>
    implements $StoredImageCopyWith<$Res> {
  _$StoredImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoredImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filePath = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoredImageImplCopyWith<$Res>
    implements $StoredImageCopyWith<$Res> {
  factory _$$StoredImageImplCopyWith(
          _$StoredImageImpl value, $Res Function(_$StoredImageImpl) then) =
      __$$StoredImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String filePath,
      @HiveField(2) DateTime createdAt});
}

/// @nodoc
class __$$StoredImageImplCopyWithImpl<$Res>
    extends _$StoredImageCopyWithImpl<$Res, _$StoredImageImpl>
    implements _$$StoredImageImplCopyWith<$Res> {
  __$$StoredImageImplCopyWithImpl(
      _$StoredImageImpl _value, $Res Function(_$StoredImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoredImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filePath = null,
    Object? createdAt = null,
  }) {
    return _then(_$StoredImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoredImageImpl implements _StoredImage {
  const _$StoredImageImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.filePath,
      @HiveField(2) required this.createdAt});

  factory _$StoredImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoredImageImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String filePath;
  @override
  @HiveField(2)
  final DateTime createdAt;

  @override
  String toString() {
    return 'StoredImage(id: $id, filePath: $filePath, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoredImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, filePath, createdAt);

  /// Create a copy of StoredImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoredImageImplCopyWith<_$StoredImageImpl> get copyWith =>
      __$$StoredImageImplCopyWithImpl<_$StoredImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoredImageImplToJson(
      this,
    );
  }
}

abstract class _StoredImage implements StoredImage {
  const factory _StoredImage(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String filePath,
      @HiveField(2) required final DateTime createdAt}) = _$StoredImageImpl;

  factory _StoredImage.fromJson(Map<String, dynamic> json) =
      _$StoredImageImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get filePath;
  @override
  @HiveField(2)
  DateTime get createdAt;

  /// Create a copy of StoredImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoredImageImplCopyWith<_$StoredImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
