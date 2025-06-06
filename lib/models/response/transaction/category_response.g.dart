// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    CategoryResponse(
      id: json['_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'icon': instance.icon,
      'color': instance.color,
    };
