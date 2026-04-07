import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'memory.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Memory extends TPromptable {
  Memory({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Memory Function(Map<String, dynamic> json) fromJsonFactory =
      _$MemoryFromJson;
  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
  static final Map<String, dynamic> Function(Memory value) toJsonFactory =
      _$MemoryToJson;
  @override
  Map<String, dynamic> toJson() => _$MemoryToJson(this);
}
