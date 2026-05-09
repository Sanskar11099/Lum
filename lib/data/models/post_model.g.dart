// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      id: json['id'] as String,
      mediaThumbUrl: json['mediaThumbUrl'] as String,
      mediaMobileUrl: json['mediaMobileUrl'] as String,
      mediaRawUrl: json['mediaRawUrl'] as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaThumbUrl': instance.mediaThumbUrl,
      'mediaMobileUrl': instance.mediaMobileUrl,
      'mediaRawUrl': instance.mediaRawUrl,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'isLiked': instance.isLiked,
    };
