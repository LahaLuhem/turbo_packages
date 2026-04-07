import 'package:turbo_promptable/workspace/abstracts/root/context.dart';

abstract class Stakeholder extends Context {
  Stakeholder({
    required super.name,
    super.metaData,
    super.config,
  });
}
