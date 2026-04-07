import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'api.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Api extends Tool {
  Api({
    required super.name,
    super.metaData,
    super.config,
  });
}
