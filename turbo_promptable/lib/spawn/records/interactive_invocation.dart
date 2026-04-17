/// Fully-composed interactive CLI invocation for a [TCliTool].
///
/// Carries the executable name and the complete, ordered argument list a
/// spawn pipeline hands to `Process.start` for an interactive TTY launch.
/// Instances are ephemeral: produced by `TCliTool.interactiveInvocation(...)`
/// and consumed once by the caller. No serialization, no persistence, no
/// equality semantics expected.
final class InteractiveInvocation {
  const InteractiveInvocation({
    required this.executable,
    required this.arguments,
  });

  /// Executable name resolved via PATH (never an absolute path).
  final String executable;

  /// Complete argument list in launch order — isolation flags plus any
  /// system prompt fragment supported in interactive mode.
  final List<String> arguments;
}
