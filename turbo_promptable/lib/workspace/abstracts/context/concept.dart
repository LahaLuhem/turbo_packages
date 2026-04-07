import 'package:turbo_promptable/workspace/abstracts/root/context.dart';

abstract class Concept extends Context {
  Concept({
    required super.name,
    super.metaData,
    super.config,
  });
}
