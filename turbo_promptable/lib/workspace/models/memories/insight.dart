import 'package:turbo_promptable/workspace/abstracts/root/memory.dart';

abstract class Insight extends TMemory {
  Insight({
    required super.name,
    super.metaData,
    super.config,
  });
}
