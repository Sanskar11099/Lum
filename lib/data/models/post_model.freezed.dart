// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  String get id => throw _privateConstructorUsedError;
  String get mediaThumbUrl => throw _privateConstructorUsedError;
  String get mediaMobileUrl => throw _privateConstructorUsedError;
  String get mediaRawUrl => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get commentCount => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
  $Res call(
      {String id,
      String mediaThumbUrl,
      String mediaMobileUrl,
      String mediaRawUrl,
      int likeCount,
      int commentCount,
      bool isLiked});
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mediaThumbUrl = null,
    Object? mediaMobileUrl = null,
    Object? mediaRawUrl = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? isLiked = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mediaThumbUrl: null == mediaThumbUrl
          ? _value.mediaThumbUrl
          : mediaThumbUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaMobileUrl: null == mediaMobileUrl
          ? _value.mediaMobileUrl
          : mediaMobileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaRawUrl: null == mediaRawUrl
          ? _value.mediaRawUrl
          : mediaRawUrl // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
          _$PostImpl value, $Res Function(_$PostImpl) then) =
      __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String mediaThumbUrl,
      String mediaMobileUrl,
      String mediaRawUrl,
      int likeCount,
      int commentCount,
      bool isLiked});
}

/// @nodoc
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
      : super(_value, _then);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mediaThumbUrl = null,
    Object? mediaMobileUrl = null,
    Object? mediaRawUrl = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? isLiked = null,
  }) {
    return _then(_$PostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mediaThumbUrl: null == mediaThumbUrl
          ? _value.mediaThumbUrl
          : mediaThumbUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaMobileUrl: null == mediaMobileUrl
          ? _value.mediaMobileUrl
          : mediaMobileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaRawUrl: null == mediaRawUrl
          ? _value.mediaRawUrl
          : mediaRawUrl // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl(
      {required this.id,
      required this.mediaThumbUrl,
      required this.mediaMobileUrl,
      required this.mediaRawUrl,
      this.likeCount = 0,
      this.commentCount = 0,
      this.isLiked = false});

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final String id;
  @override
  final String mediaThumbUrl;
  @override
  final String mediaMobileUrl;
  @override
  final String mediaRawUrl;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int commentCount;
  @override
  @JsonKey()
  final bool isLiked;

  @override
  String toString() {
    return 'Post(id: $id, mediaThumbUrl: $mediaThumbUrl, mediaMobileUrl: $mediaMobileUrl, mediaRawUrl: $mediaRawUrl, likeCount: $likeCount, commentCount: $commentCount, isLiked: $isLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mediaThumbUrl, mediaThumbUrl) ||
                other.mediaThumbUrl == mediaThumbUrl) &&
            (identical(other.mediaMobileUrl, mediaMobileUrl) ||
                other.mediaMobileUrl == mediaMobileUrl) &&
            (identical(other.mediaRawUrl, mediaRawUrl) ||
                other.mediaRawUrl == mediaRawUrl) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, mediaThumbUrl,
      mediaMobileUrl, mediaRawUrl, likeCount, commentCount, isLiked);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(
      this,
    );
  }
}

abstract class _Post implements Post {
  const factory _Post(
      {required final String id,
      required final String mediaThumbUrl,
      required final String mediaMobileUrl,
      required final String mediaRawUrl,
      final int likeCount,
      final int commentCount,
      final bool isLiked}) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  String get id;
  @override
  String get mediaThumbUrl;
  @override
  String get mediaMobileUrl;
  @override
  String get mediaRawUrl;
  @override
  int get likeCount;
  @override
  int get commentCount;
  @override
  bool get isLiked;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
