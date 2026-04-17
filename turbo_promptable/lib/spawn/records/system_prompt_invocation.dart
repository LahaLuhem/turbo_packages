/// Describes how a given [TCliTool] accepts a system prompt for a
/// non-interactive launch.
///
/// Sealed hierarchy consumed by the spawn pipeline's argv composer:
/// - [SystemPromptArgv] — tool accepts the system prompt via a flag
///   (inline-text or file-path; the distinction lives inside
///   `TCliTool.systemPromptInvocation(...)` and is already collapsed
///   into a resolved argv fragment here).
/// - [SystemPromptConfigFile] — tool configures the system prompt via
///   a file written outside the CLI invocation. Carries the absolute
///   path + contents the consumer must persist plus any argv fragment
///   the launch still requires (often empty).
/// - [SystemPromptUnsupported] — tool has no documented non-interactive
///   mechanism. The consumer raises a domain exception.
///
/// Instances are ephemeral: created inside `TCliTool.systemPromptInvocation`
/// and consumed once by `SpawnService` before being discarded. No
/// serialization, no persistence, no equality semantics expected.
sealed class SystemPromptInvocation {
  const SystemPromptInvocation();
}

/// Tool accepts the system prompt via a CLI flag. The enum value has
/// already resolved which content to embed (inline rendered text or
/// the rendered file path) and returns the complete argv fragment.
///
/// The consumer splices [argv] into the process arguments verbatim.
final class SystemPromptArgv extends SystemPromptInvocation {
  const SystemPromptArgv(this.argv);

  /// Resolved argv fragment — typically `[flag, value]`. May be longer
  /// if a tool's documented shape requires multiple prefix flags.
  final List<String> argv;
}

/// Tool configures the system prompt via a config file written to
/// disk. The consumer writes [configContents] to [configPath] before
/// launch, then extends the process argv with [argv].
///
/// **Cleanup note**: this variant deliberately does NOT specify when
/// the config file is cleaned up. A future task that wires any
/// concrete tool through this variant must decide how ownership
/// interacts with `SpawnManifest.files` so `DespawnService` can
/// collect the file on spawn exit — ideally by tracking [configPath]
/// on the manifest alongside other per-spawn artifacts.
final class SystemPromptConfigFile extends SystemPromptInvocation {
  const SystemPromptConfigFile({
    required this.configPath,
    required this.configContents,
    required this.argv,
  });

  /// Absolute path the consumer must write [configContents] to before
  /// process launch.
  final String configPath;

  /// Exact bytes (as a Dart string) to persist at [configPath]. The
  /// consumer writes UTF-8.
  final String configContents;

  /// Additional argv fragment to splice after the config file is
  /// written. Typically empty for pure config-file mechanisms.
  final List<String> argv;
}

/// Tool has no documented non-interactive system-prompt mechanism.
///
/// The consumer raises a named domain exception before any filesystem
/// mutation or process launch so partial spawn state cannot be left
/// behind.
final class SystemPromptUnsupported extends SystemPromptInvocation {
  const SystemPromptUnsupported();
}
