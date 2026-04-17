import 'package:turbo_promptable/spawn/records/headless_invocation.dart';
import 'package:turbo_promptable/spawn/records/interactive_invocation.dart';
import 'package:turbo_promptable/spawn/records/system_prompt_invocation.dart';

enum TCliTool {
  /// Anthropic Claude Code CLI.
  ///
  /// Invocation surface:
  /// - [command] resolves to `claude` on PATH.
  /// - [systemPromptInvocation] returns [SystemPromptArgv] for the
  ///   path-valued flag `--system-prompt-file`.
  /// - [isolationArgv] returns `['--strict-mcp-config']` so the child
  ///   loads zero MCP servers while OAuth / keychain auth remain intact.
  /// - [headlessInvocation] shapes the user prompt as the positional
  ///   argument after `-p`.
  /// Source: https://docs.claude.com/en/docs/claude-code/cli-reference
  /// Checked: 2026-04-17.
  claude,

  /// OpenAI Codex CLI.
  ///
  /// Invocation surface:
  /// - [command] resolves to `codex` on PATH.
  /// - [systemPromptInvocation] returns [SystemPromptUnsupported] —
  ///   codex exposes no `--system-prompt*` flag. Headless launches
  ///   stitch the rendered system prompt onto the request body inside
  ///   [headlessInvocation]; interactive launches deliver the system
  ///   prompt via `AGENTS.md` at cwd (outside this package).
  /// - [isolationArgv] returns `['-c', 'mcp_servers={}']` so the child
  ///   loads zero MCP servers. `CODEX_HOME` is NOT redirected —
  ///   auth.json lives under `~/.codex/` and redirection would break
  ///   Codex subscription auth.
  /// Source: https://github.com/openai/codex
  /// Checked: 2026-04-17.
  codex,

  /// Cursor Agent CLI.
  ///
  /// Invocation surface:
  /// - [command] resolves to `cursor-agent` on PATH. The binary's own
  ///   `--help` names the executable `agent`, but `cursor-agent` is the
  ///   published package name and avoids PATH collisions with other
  ///   `agent` binaries.
  /// - [systemPromptInvocation] returns [SystemPromptUnsupported] —
  ///   cursor-agent exposes no `--system-prompt*` flag. Headless
  ///   launches stitch the rendered system prompt onto the request
  ///   body inside [headlessInvocation]; interactive launches deliver
  ///   the system prompt via `AGENTS.md` at cwd (outside this package).
  /// - [isolationArgv] is empty: cursor-agent's documented CLI surface
  ///   exposes no flag or environment variable to disable user-global
  ///   MCP servers. See the `isolationArgv` doc comment for the gap.
  /// Source: https://docs.cursor.com/en/cli/reference/parameters
  /// Checked: 2026-04-17.
  cursor,
  ;

  String get command {
    switch (this) {
      case TCliTool.claude:
        // Source: https://docs.claude.com/en/docs/claude-code/cli-reference
        // Checked: 2026-04-17.
        return 'claude';
      case TCliTool.codex:
        // Source: https://github.com/openai/codex
        // Checked: 2026-04-17.
        return 'codex';
      case TCliTool.cursor:
        // Source: https://docs.cursor.com/en/cli/reference/parameters
        // Checked: 2026-04-17.
        return 'cursor-agent';
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
  /// non-interactive launch via a CLI flag.
  ///
  /// The caller must already have rendered the system prompt to a
  /// string and written it to an absolute path on disk.
  /// - [renderedPromptContent] is the verbatim rendered prompt text
  ///   (used by tools whose flag takes inline text).
  /// - [renderedPromptPath] is the absolute path on disk (used by
  ///   tools whose flag takes a file path or whose mechanism writes
  ///   a sidecar config file).
  ///
  /// Per-tool resolution:
  /// - [TCliTool.claude]: `SystemPromptArgv(['--system-prompt-file',
  ///   renderedPromptPath])` — path-valued flag.
  /// - [TCliTool.codex]: [SystemPromptUnsupported] — no documented
  ///   flag. Headless launches stitch the rendered prompt onto the
  ///   request body via [headlessInvocation].
  /// - [TCliTool.cursor]: [SystemPromptUnsupported] — no documented
  ///   flag. Headless launches stitch the rendered prompt onto the
  ///   request body via [headlessInvocation].
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

  /// Per-tool argv fragment that strips user-global MCP server
  /// inheritance from any child launch. SAFE on both interactive and
  /// headless launches; never affects authentication.
  List<String> get isolationArgv {
    switch (this) {
      case TCliTool.claude:
        // `--strict-mcp-config` — child loads only MCP servers from
        // `--mcp-config`. With no paired `--mcp-config`, the child
        // loads zero MCP servers. OAuth / keychain auth untouched.
        // Source: https://docs.claude.com/en/docs/claude-code/cli-reference
        // Checked: 2026-04-17.
        return const ['--strict-mcp-config'];
      case TCliTool.codex:
        // `-c mcp_servers={}` — per-invocation config override empties
        // the `mcp_servers` table. Highest precedence over
        // `~/.codex/config.toml`. Auth and all other config intact.
        // `CODEX_HOME` is NOT redirected: it would break subscription
        // auth stored at `~/.codex/auth.json`.
        // Source: https://github.com/openai/codex
        // Checked: 2026-04-17.
        return const ['-c', 'mcp_servers={}'];
      case TCliTool.cursor:
        // No documented flag or environment variable disables
        // user-global MCP servers for cursor-agent. The invariant is
        // surfaced here as an empty list so a future cursor release
        // can be wired with a one-line change.
        // Source: https://docs.cursor.com/en/cli/reference/parameters
        // Checked: 2026-04-17.
        return const <String>[];
    }
  }

  /// Fully-composed non-interactive launch argv for this tool.
  ///
  /// - [requestBody] is the user's request body read from the request
  ///   file by the spawn pipeline.
  /// - [systemPromptArgv] is the pre-resolved system-prompt fragment
  ///   for tools that accept a flag (claude); ignored by tools that
  ///   stitch the rendered prompt onto the request body (codex,
  ///   cursor).
  /// - [renderedSystemPrompt] is the rendered system prompt text for
  ///   the current spawn; used by stitching tools.
  HeadlessInvocation headlessInvocation({
    required String requestBody,
    required List<String> systemPromptArgv,
    required String renderedSystemPrompt,
  }) {
    switch (this) {
      case TCliTool.claude:
        // Source: https://docs.claude.com/en/docs/claude-code/cli-reference
        // Checked: 2026-04-17.
        return HeadlessInvocation(
          executable: 'claude',
          arguments: [
            ...isolationArgv,
            ...systemPromptArgv,
            '-p',
            requestBody,
          ],
        );
      case TCliTool.codex:
        // Source: https://github.com/openai/codex
        // Checked: 2026-04-17.
        return HeadlessInvocation(
          executable: 'codex',
          arguments: [
            'exec',
            ...isolationArgv,
            _stitchSystemPromptAndRequest(renderedSystemPrompt, requestBody),
          ],
        );
      case TCliTool.cursor:
        // Source: https://docs.cursor.com/en/cli/reference/parameters
        // Checked: 2026-04-17.
        return HeadlessInvocation(
          executable: 'cursor-agent',
          arguments: [
            ...isolationArgv,
            '-p',
            _stitchSystemPromptAndRequest(renderedSystemPrompt, requestBody),
          ],
        );
    }
  }

  /// Fully-composed interactive launch argv for this tool.
  ///
  /// - [systemPromptArgv] is the pre-resolved system-prompt fragment
  ///   for tools that accept a flag (claude); ignored by codex and
  ///   cursor, which rely on `AGENTS.md` delivery at cwd for
  ///   interactive mode (outside this package).
  InteractiveInvocation interactiveInvocation({
    required List<String> systemPromptArgv,
  }) {
    switch (this) {
      case TCliTool.claude:
        // Source: https://docs.claude.com/en/docs/claude-code/cli-reference
        // Checked: 2026-04-17.
        return InteractiveInvocation(
          executable: 'claude',
          arguments: [
            ...isolationArgv,
            ...systemPromptArgv,
          ],
        );
      case TCliTool.codex:
        // Source: https://github.com/openai/codex
        // Checked: 2026-04-17.
        return InteractiveInvocation(
          executable: 'codex',
          arguments: [...isolationArgv],
        );
      case TCliTool.cursor:
        // Source: https://docs.cursor.com/en/cli/reference/parameters
        // Checked: 2026-04-17.
        return InteractiveInvocation(
          executable: 'cursor-agent',
          arguments: [...isolationArgv],
        );
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
}

/// Wraps a rendered system prompt and a user request body into a single
/// text payload with XML-tagged boundaries. Used by [TCliTool.codex] and
/// [TCliTool.cursor] headless invocations, neither of which exposes a
/// `--system-prompt*` flag.
///
/// The output is deterministic and preserves the boundary tags even when
/// either input is empty. XML tags are chosen because Anthropic and
/// OpenAI prompt-engineering guidance both report reliable handling of
/// XML-delimited sections by their model backends; Markdown headings
/// would risk collision with user-authored Markdown in the request body.
String _stitchSystemPromptAndRequest(
  String renderedSystemPrompt,
  String requestBody,
) {
  return '<system-prompt>\n'
      '$renderedSystemPrompt\n'
      '</system-prompt>\n'
      '\n'
      '<user-request>\n'
      '$requestBody\n'
      '</user-request>';
}
