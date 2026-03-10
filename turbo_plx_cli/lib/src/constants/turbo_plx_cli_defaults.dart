abstract final class TurboPlxCliDefaults {
  TurboPlxCliDefaults._();

  static const int throttleMs = 1000;
  static const List<String> extensions = ['.md'];
  static const List<String> ignoreFolders = [
    '.git',
    'node_modules',
    'build',
    '.dart_tool',
    '.plx',
  ];

  static const plxExecutable = 'plx';
  static const requestTimeout = Duration(seconds: 30);
}
