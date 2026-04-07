import 'package:turbo_promptable/workspace/abstracts/root/context.dart';

abstract class Subject extends Context {
  Subject({
    required super.name,
    super.metaData,
    super.config,
  });
}
