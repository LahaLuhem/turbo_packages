import 'package:turbo_promptable/spawn/models/t_file.dart';
import 'package:turbo_promptable/spawn/models/t_folder.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

/// Configuration for spawning a set of promptable files and folders on disk.
class TSpawnConfig {
  const TSpawnConfig({
    required this.root,
    required this.systemPrompt,
    required this.folders,
    required this.files,
  });

  final String root;
  final TPromptable systemPrompt;
  final List<TFolder> folders;
  final List<TFile> files;
}
