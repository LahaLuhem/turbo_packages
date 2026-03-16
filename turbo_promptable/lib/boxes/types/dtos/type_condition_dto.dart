import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/boxes/types/enums/type_condition_field.dart';
import 'package:turbo_promptable/boxes/types/enums/type_condition_operator.dart';

part 'type_condition_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TypeConditionDto {
  TypeConditionDto({
    required this.field,
    required this.operator,
    required this.value,
  });

  @JsonKey(
    fromJson: TypeConditionField.fromJson,
    toJson: _fieldToJson,
  )
  final TypeConditionField field;

  @JsonKey(
    fromJson: TypeConditionOperator.fromJson,
    toJson: _operatorToJson,
  )
  final TypeConditionOperator operator;

  final String value;

  TypeConditionDto copyWith({
    TypeConditionField? field,
    TypeConditionOperator? operator,
    String? value,
  }) => TypeConditionDto(
    field: field ?? this.field,
    operator: operator ?? this.operator,
    value: value ?? this.value,
  );

  Map<String, dynamic> toJson() => _$TypeConditionDtoToJson(this);
  factory TypeConditionDto.fromJson(Map<String, dynamic> json) =>
      _$TypeConditionDtoFromJson(json);
  static const fromJsonFactory = _$TypeConditionDtoFromJson;
  static const toJsonFactory = _$TypeConditionDtoToJson;
}

String _fieldToJson(TypeConditionField value) => value.toJson();
String _operatorToJson(TypeConditionOperator value) => value.toJson();
