import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';

part 'collection.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  genericArgumentFactories: true,
)
abstract class Collection<T extends Object> extends Context {
  Collection({
    required super.name,
    super.config,
    super.metaData,
    required this.items,
  });

  final List<T> items;
}
