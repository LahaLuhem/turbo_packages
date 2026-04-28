import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

class TModel<DTO extends TWriteableId> {
  const TModel({
    required this.dto,
  });

  final DTO dto;

  TModel.fromDto(this.dto);

  String get id => dto.id;

  MODEL copyWith<MODEL extends TModel<DTO>>({
    DTO? dto,
  }) =>
      TModel(
            dto: dto ?? this.dto,
          )
          as MODEL;
}
