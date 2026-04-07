
import 'package:turbo_promptable/workspace/models/root/checklist.dart';

abstract class NonGoals extends Checklist {
  NonGoals({
    required super.name,
    required super.items,
    super.config,
  });
}
