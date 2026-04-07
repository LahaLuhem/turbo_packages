
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

class TFile {
  final TPromptable promptable;
  final String? _fileName;

  const TFile({
    required this.promptable,
    String? fileName,
  }) : _fileName = fileName;

  String get fileName => _fileName ?? promptable.fileName;
}
