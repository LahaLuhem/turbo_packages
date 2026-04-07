import 'package:turbo_promptable/workspace/abstracts/root/context.dart';

abstract class Documentation extends Context {
  Documentation({
    required super.name,
    super.metaData,
    super.config,
  });
}
