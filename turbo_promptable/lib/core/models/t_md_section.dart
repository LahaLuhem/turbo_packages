/// A titled section of Markdown body content produced by a [TConfig.bodyBuilder].
class TMdSection {
  const TMdSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
