import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'memory.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Memory extends TPromptable {
  const Memory({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MemoryToJson(this);
}
