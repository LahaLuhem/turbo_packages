import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/t_md_section.dart';

typedef TBodyBuilderDef<T extends TPromptable> = List<TMdSection> Function(T promptable);
