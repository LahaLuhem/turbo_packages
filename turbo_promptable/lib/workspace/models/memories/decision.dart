import 'package:turbo_promptable/workspace/abstracts/root/memory.dart';

abstract class Decision extends TMemory {
  Decision({
    required super.name,
    super.metaData,
    super.config,
  });
}
