enum TCliTool {
  /// Anthropic Claude Code CLI.
  ///
  /// Headless: **unwired**.
  /// Source: https://code.claude.com/docs/en/cli-reference
  /// Checked: 2026-04-17.
  /// Rationale: Non-interactive mode (`claude -p "<prompt>"`) takes the
  /// user prompt as a POSITIONAL string argument. There is no flag that
  /// accepts a user-request FILE PATH. Additionally, `--system-prompt`
  /// accepts inline text; the separate `--system-prompt-file` takes a
  /// path. The fixed headless argv contract
  /// `[systemPromptFlag, <path>, requestFlag, <path>]` cannot be
  /// expressed with Claude Code's documented flag shape, so both
  /// `headlessCommand` and `requestFlag` remain null. Revisiting
  /// requires either the spec's argv contract to evolve or a
  /// Claude-specific invoker.
  claude,

  /// OpenAI Codex CLI.
  ///
  /// Headless: **unwired**.
  /// Source: https://developers.openai.com/codex/cli/reference
  /// Checked: 2026-04-17.
  /// Rationale: The non-interactive subcommand is `codex exec`, which
  /// takes the prompt as a POSITIONAL string or reads it from stdin
  /// via `-`. No flag accepts a user-request file path. The current
  /// documented flag set contains no `--system`/`--system-prompt`
  /// entry either — system behavior is configured via
  /// `~/.codex/config.toml`. Neither half of the fixed
  /// `[systemPromptFlag, <path>, requestFlag, <path>]` contract is
  /// satisfied, so both fields remain null.
  codex,

  /// Cursor Agent CLI (executable name: `agent`).
  ///
  /// Headless: **unwired**.
  /// Source: https://cursor.com/docs/cli/reference/parameters
  /// Checked: 2026-04-17.
  /// Rationale: Non-interactive mode is `agent -p "<prompt>"`; the
  /// prompt is a POSITIONAL string and no flag takes a user-request
  /// file path. The documented parameter table lists no
  /// `--system`/`--system-prompt` flag either. The fixed
  /// `[systemPromptFlag, <path>, requestFlag, <path>]` contract cannot
  /// be expressed, so both fields remain null.
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

  String get systemPromptFlag {
    switch (this) {
      case TCliTool.claude:
        return '--system-prompt';
      case TCliTool.codex:
        return '--system';
      case TCliTool.cursor:
        return '--system';
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
  /// `[...headlessCommand, systemPromptFlag, <systemPromptPath>,
  /// requestFlag, <requestFilePath>]`. `null` means this tool has no
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
