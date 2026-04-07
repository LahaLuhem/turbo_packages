import 'package:turbo_promptable/workspace/abstracts/root/spec.dart';

export 'package:turbo_promptable/workspace/abstracts/root/spec.dart';

abstract class TRequirement extends Spec {
  TRequirement({
    required super.name,
    super.metaData,
    super.config,
  });
}
