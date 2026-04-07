
import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/t_section.dart';

typedef TMdSectionsBuilder<T extends TPromptable> = List<TMdSection> Function(T promptable);
