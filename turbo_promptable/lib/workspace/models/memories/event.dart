import 'package:turbo_promptable/workspace/abstracts/root/memory.dart';

abstract class Event extends TMemory {
  Event({
    required super.name,
    super.metaData,
    super.config,
  });
}
