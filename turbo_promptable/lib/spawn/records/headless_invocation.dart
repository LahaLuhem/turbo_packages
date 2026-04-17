/// Fully-composed non-interactive CLI invocation for a [TCliTool].
///
/// Carries the executable name and the complete, ordered argument list a
/// spawn pipeline hands to `Process.start` for a headless launch. Instances
/// are ephemeral: produced by `TCliTool.headlessInvocation(...)` and
/// consumed once by the caller. No serialization, no persistence, no
/// equality semantics expected.
final class HeadlessInvocation {
  const HeadlessInvocation({
    required this.executable,
    required this.arguments,
  });

  /// Executable name resolved via PATH (never an absolute path).
  final String executable;

  /// Complete argument list in launch order — isolation flags, any system
  /// prompt fragment, and the request body (verbatim or stitched, per tool).
  final List<String> arguments;
}
