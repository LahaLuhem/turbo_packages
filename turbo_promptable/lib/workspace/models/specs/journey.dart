import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'journey.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TJourney extends Spec {
  const TJourney({
    required super.name,
    super.metaData,
    super.config,
  });

  factory TJourney.fromJson(Map<String, dynamic> json) =>
      _$TJourneyFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TJourneyToJson(this);
}
