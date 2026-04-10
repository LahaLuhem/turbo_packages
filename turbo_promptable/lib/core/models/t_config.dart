import 'package:turbo_promptable/core/typedefs/t_body_builder_def.dart';

/// Controls how a [TPromptable] renders its Markdown output.
///
/// Set [bodyBuilder] to supply custom body sections, [leadingBody] /
/// [trailingBody] for static content before/after the body, and
/// [inheritMetaData] to propagate name/description into frontmatter.
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
