import 'package:turbo_promptable/core/typedefs/t_body_builder_def.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_meta_data.dart';

class TConfig {
  const TConfig({
    this.bodyBuilder,
    this.inheritMetaData = true,
    this.leadingBody,
    this.trailingBody,
  });

  final String? leadingBody;
  final TBodyBuilderDef? bodyBuilder;
  final String? trailingBody;
  final bool inheritMetaData;
}
