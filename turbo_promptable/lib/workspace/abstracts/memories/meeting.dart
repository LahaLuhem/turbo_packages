import 'package:turbo_promptable/workspace/abstracts/root/memory.dart';

abstract class Meeting extends TMemory {
  Meeting({
    required super.name,
    super.metaData,
    super.config,
  });
}
