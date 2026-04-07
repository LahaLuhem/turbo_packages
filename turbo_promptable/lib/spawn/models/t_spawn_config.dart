import 'package:turbo_promptable/spawn/models/t_file.dart';
import 'package:turbo_promptable/spawn/models/t_folder.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';

class TSpawnConfig {
  const TSpawnConfig({
    required this.root, required this.systemPrompt, required this.folders, required this.files,
  });

  final String root;
  final TPromptable systemPrompt;
  final List<TFolder> folders;
  final List<TFile> files;
}
