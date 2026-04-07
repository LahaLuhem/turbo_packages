import 'package:turbo_promptable/workspace/abstracts/root/checklist.dart';

abstract class AcceptanceCriteria extends Checklist {
  AcceptanceCriteria({
    required super.name,
    required super.items,
    super.config,
  });
}
