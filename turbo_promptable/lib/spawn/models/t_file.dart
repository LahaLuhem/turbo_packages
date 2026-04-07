import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

class TFile {
  final TPromptable value;
  final String? _fileName;

  const TFile({
    required this.value,
    String? fileName,
  }) : _fileName = fileName;

  String get fileName => _fileName ?? value.fileName;
}
