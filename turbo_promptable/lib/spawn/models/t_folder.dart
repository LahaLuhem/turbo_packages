import 'package:turbo_promptable/spawn/models/t_file.dart';

class TFolder {
  final String path;
  final List<TFile> files;

  const TFolder({
    required this.path,
    required this.files,
  });
}
