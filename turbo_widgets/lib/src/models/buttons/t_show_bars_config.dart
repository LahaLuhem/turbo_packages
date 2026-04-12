class TShowBarsConfig {
  TShowBarsConfig({required this.showNavigationBar});

  final bool showNavigationBar;

  TShowBarsConfig copyWith({
    bool? showNavigationBar,
  }) {
    return TShowBarsConfig(
      showNavigationBar: showNavigationBar ?? this.showNavigationBar,
    );
  }
}
