import 'package:turbo_promptable/shared/dtos/meta_data_dto.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

abstract class TurboPromptable extends TSerializable {
  const TurboPromptable({
    required this.metaData,
  });

  final MetaDataDto? metaData;
}
