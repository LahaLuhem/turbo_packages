import 'package:turbo_promptable/workspace/models/root/context.dart';

abstract class Actor extends Context {
  Actor({
    required super.name,
    super.metaData,
    super.config,
  });
}
