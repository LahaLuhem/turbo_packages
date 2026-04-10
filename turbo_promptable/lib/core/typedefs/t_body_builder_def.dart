import 'package:turbo_promptable/core/models/t_md_section.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

typedef TBodyBuilderDef<T extends TPromptable> =
    List<TMdSection> Function(T promptable);
