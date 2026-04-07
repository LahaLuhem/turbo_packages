import 'package:turbo_promptable/workspace/abstracts/root/checklist.dart';

abstract class Constraints extends Checklist {
  Constraints({
    required super.name,
    required super.items,
    super.config,
  });
}
