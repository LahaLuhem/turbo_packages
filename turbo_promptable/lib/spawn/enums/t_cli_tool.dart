import 'package:turbo_promptable/spawn/records/system_prompt_invocation.dart';

enum TCliTool {
  /// Anthropic Claude Code CLI.
  ///
  /// System prompt: **wired** via path-valued flag `--system-prompt-file`.
  /// Headless (request file): **unwired**.
  /// Source: https://code.claude.com/docs/en/cli-reference
  /// Checked: 2026-04-17.
  /// Rationale: `--system-prompt` accepts inline text; `--system-prompt-file`
  /// takes a path — the spawn pipeline already writes the rendered
  /// system prompt to disk per spawn, so the file-path flag is the
  /// direct fit. The non-interactive user prompt (`claude -p
  /// "<prompt>"`) is still POSITIONAL with no path-valued flag
  /// equivalent, so the fixed headless argv contract
  /// `[..., requestFlag, <path>]` cannot be expressed and both
  /// `headlessCommand` and `requestFlag` stay null.
  claude,

  /// OpenAI Codex CLI.
  ///
  /// System prompt: **unsupported** in dev-16 (see [systemPromptInvocation]).
  /// Headless (request file): **unwired**.
  /// Source: https://developers.openai.com/codex/cli/reference
  /// Checked: 2026-04-17.
  /// Rationale: System behavior is configured via `~/.codex/config.toml`,
  /// not a CLI flag. Wiring a per-spawn config file write (including
  /// its manifest tracking and cleanup in `DespawnService`) is a
  /// distinct design spike out of scope for dev-16; this value
  /// returns [SystemPromptUnsupported] until that work lands. The
  /// non-interactive subcommand `codex exec` also takes the user
  /// prompt as a POSITIONAL string or via stdin `-` and exposes no
  /// request-file flag, so `headlessCommand` and `requestFlag`
  /// remain null.
  codex,

  /// Cursor Agent CLI (executable name: `agent`).
  ///
  /// System prompt: **unsupported** (see [systemPromptInvocation]).
  /// Headless (request file): **unwired**.
  /// Source: https://cursor.com/docs/cli/reference/parameters
  /// Checked: 2026-04-17.
  /// Rationale: The documented parameter table lists no
  /// `--system`/`--system-prompt` flag and no request-file flag.
  /// Non-interactive mode is `agent -p "<prompt>"` with a POSITIONAL
  /// prompt. Both the system-prompt and headless halves stay
  /// unwired.
  cursor,
  ;

  String get command {
    switch (this) {
      case TCliTool.claude:
        return 'claude';
      case TCliTool.codex:
        return 'codex';
      case TCliTool.cursor:
        return 'agent';
    }
  }

  String get yoloFlag {
    switch (this) {
      case TCliTool.claude:
        return '--dangerously-skip-permissions';
      case TCliTool.codex:
        return '--yolo';
      case TCliTool.cursor:
        return '--yolo';
    }
  }

  /// Describes how this tool accepts a system prompt for a
  /// non-interactive launch.
  ///
  /// The caller must already have rendered the system prompt to a
  /// string and written it to an absolute path on disk.
  /// - [renderedPromptContent] is the verbatim rendered prompt text
  ///   (used by tools whose flag takes inline text).
  /// - [renderedPromptPath] is the absolute path on disk (used by
  ///   tools whose flag takes a file path or whose mechanism writes
  ///   a sidecar config file).
  ///
  /// Per-tool resolution (checked 2026-04-17, see enum-value doc
  /// comments above):
  /// - [TCliTool.claude]: `SystemPromptArgv(['--system-prompt-file',
  ///   renderedPromptPath])` — path-valued flag.
  /// - [TCliTool.codex]: [SystemPromptUnsupported] (config-file
  ///   mechanism exists but wiring is out of scope for dev-16).
  /// - [TCliTool.cursor]: [SystemPromptUnsupported] (no documented
  ///   mechanism).
  ///
  /// The inline-text-flag variant is modeled by the same
  /// [SystemPromptArgv] shape — an enum value wanting that shape
  /// would return `SystemPromptArgv([inlineFlag, renderedPromptContent])`.
  /// No current tool exercises it; the enum surface supports it so
  /// a future value can opt in without consumer changes.
  SystemPromptInvocation systemPromptInvocation({
    required String renderedPromptContent,
    required String renderedPromptPath,
  }) {
    switch (this) {
      case TCliTool.claude:
        return SystemPromptArgv(
          ['--system-prompt-file', renderedPromptPath],
        );
      case TCliTool.codex:
        return const SystemPromptUnsupported();
      case TCliTool.cursor:
        return const SystemPromptUnsupported();
    }
  }

  String get bareMcpFlag {
    switch (this) {
      case TCliTool.claude:
        return '--strict-mcp-config';
      case TCliTool.codex:
        return '--bare-mcp';
      case TCliTool.cursor:
        return '--bare-mcp';
    }
  }

  String get mcpConfigFlag {
    switch (this) {
      case TCliTool.claude:
        return '--mcp-config';
      case TCliTool.codex:
        return '--mcp-config';
      case TCliTool.cursor:
        return '--mcp-config';
    }
  }

  String get homeFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '.claude';
      case TCliTool.codex:
        return '.codex';
      case TCliTool.cursor:
        return '.cursor';
    }
  }

  String get mcpFilePath {
    switch (this) {
      case TCliTool.claude:
        return '.mcp.json';
      case TCliTool.codex:
        return '$homeFolderPath/mcp.json';
      case TCliTool.cursor:
        return '$homeFolderPath/mcp.json';
    }
  }

  String get promptFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '$homeFolderPath/commands';
      case TCliTool.codex:
        return '$homeFolderPath/prompts';
      case TCliTool.cursor:
        return '$homeFolderPath/commands';
    }
  }

  String get agentsFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '$homeFolderPath/agents';
      case TCliTool.codex:
        return '$homeFolderPath/agents';
      case TCliTool.cursor:
        return '$homeFolderPath/agents';
    }
  }

  String get skillsFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '$homeFolderPath/skills';
      case TCliTool.codex:
        return '$homeFolderPath/skills';
      case TCliTool.cursor:
        return '$homeFolderPath/skills';
    }
  }

  String get sourcesOverrideFlag {
    switch (this) {
      case TCliTool.claude:
        return '--setting-sources';
      case TCliTool.codex:
        return '--sources';
      case TCliTool.cursor:
        return '--sources';
    }
  }

  /// Non-interactive launch shape for `SpawnDeliveryMode.headless`.
  ///
  /// When populated, the first element is the executable and the
  /// remaining elements are fixed leading flags that go before any
  /// per-spawn arguments (system prompt, request file). `null` means
  /// this tool has no documented non-interactive invocation that
  /// matches the fixed headless argv contract; the spawn pipeline
  /// raises [CliToolNotHeadlessCapableException] in that case.
  ///
  /// dev-13 (2026-04-17): after checking the official CLI references
  /// for all three tools, every value remains `null`. See the per-
  /// value doc comments above for the vendor URL, checked date, and
  /// the specific flag-shape mismatch that prevents wiring.
  List<String>? get headlessCommand {
    switch (this) {
      case TCliTool.claude:
        return null;
      case TCliTool.codex:
        return null;
      case TCliTool.cursor:
        return null;
    }
  }

  /// Flag that precedes the per-spawn request-file path in the
  /// headless argv.
  ///
  /// When populated, the resulting argv is
  /// `[...headlessCommand, ...systemPromptArgv, requestFlag,
  /// <requestFilePath>]` where `systemPromptArgv` is the resolved
  /// fragment from [systemPromptInvocation]. `null` means this tool
  /// has no
  /// documented flag that accepts a request-file PATH in
  /// non-interactive mode.
  ///
  /// dev-13 (2026-04-17): all three tools take the user prompt as a
  /// positional string (or stdin) rather than a path-valued flag, so
  /// every value remains `null`. See the per-value doc comments above
  /// for the vendor URL and checked date.
  String? get requestFlag {
    switch (this) {
      case TCliTool.claude:
        return null;
      case TCliTool.codex:
        return null;
      case TCliTool.cursor:
        return null;
    }
  }
}
