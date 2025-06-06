import 'package:json_annotation/json_annotation.dart';

part 'category_response.g.dart';

@JsonSerializable()
class CategoryResponse {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String type;
  final String icon;
  final String color;

  CategoryResponse({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}
