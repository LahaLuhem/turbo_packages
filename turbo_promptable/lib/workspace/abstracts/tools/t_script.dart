import 'package:turbo_promptable/workspace/abstracts/root/t_tool.dart';

abstract class TScript extends Tool {
  TScript({
    required super.name,
    super.description,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
  });
}
