import 'package:turbo_promptable/spawn/models/t_file.dart';

/// A directory containing [TFile] entries to be spawned on disk.
class TFolder {
  final String path;
  final List<TFile> files;

  const TFolder({
    required this.path,
    required this.files,
  });
}
