import 'package:turbo_promptable/workspace/abstracts/root/memory.dart';

abstract class Progress extends TMemory {
  Progress({
    required super.name,
    super.metaData,
    super.config,
  });
}
